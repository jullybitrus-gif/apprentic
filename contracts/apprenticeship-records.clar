;; Apprenticeship Records Contract - NFT Credential Management
;; This contract manages the creation, ownership, and verification of NFT-based
;; apprenticeship credentials and training certificates.

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-credential (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-not-authorized-issuer (err u105))
(define-constant err-credential-expired (err u106))
(define-constant err-invalid-transfer (err u107))

;; Credential Status Types
(define-constant status-active u1)
(define-constant status-expired u2)
(define-constant status-revoked u3)
(define-constant status-pending u4)

;; Competency Levels
(define-constant level-beginner u1)
(define-constant level-intermediate u2)
(define-constant level-advanced u3)
(define-constant level-expert u4)

;; Data Variables
(define-data-var credential-counter uint u0)
(define-data-var contract-admin principal tx-sender)

;; NFT Definition
(define-non-fungible-token apprenticeship-credential uint)

;; Data Maps
(define-map credentials
    { credential-id: uint }
    {
        apprentice: principal,
        issuer: principal,
        skill-name: (string-ascii 100),
        training-program: (string-ascii 100),
        competency-level: uint,
        completion-date: uint,
        expiry-date: (optional uint),
        status: uint,
        verification-hash: (string-ascii 64),
        metadata-uri: (optional (string-ascii 200)),
        prerequisites-met: bool,
        assessment-score: (optional uint)
    }
)

(define-map authorized-issuers
    { issuer: principal }
    {
        organization-name: (string-ascii 100),
        contact-info: (string-ascii 150),
        accreditation-level: uint,
        is-active: bool,
        registered-date: uint,
        credentials-issued: uint
    }
)

(define-map apprentice-progress
    { apprentice: principal, skill-area: (string-ascii 50) }
    {
        current-level: uint,
        credentials-earned: uint,
        last-updated: uint,
        total-training-hours: uint,
        mentor-assigned: (optional principal)
    }
)

(define-map skill-requirements
    { skill-name: (string-ascii 100) }
    {
        minimum-training-hours: uint,
        prerequisites: (list 10 (string-ascii 100)),
        assessment-required: bool,
        industry-category: (string-ascii 50),
        difficulty-rating: uint
    }
)

(define-map credential-verification
    { verification-code: (string-ascii 32) }
    {
        credential-id: uint,
        verified-by: principal,
        verification-date: uint,
        is-valid: bool
    }
)

;; Public Functions

;; Mint a new apprenticeship credential NFT
(define-public (mint-credential
    (apprentice principal)
    (skill-name (string-ascii 100))
    (training-program (string-ascii 100))
    (competency-level uint)
    (expiry-date (optional uint))
    (verification-hash (string-ascii 64))
    (metadata-uri (optional (string-ascii 200)))
    (assessment-score (optional uint)))
    (let
        (
            (credential-id (+ (var-get credential-counter) u1))
            (current-time burn-block-height)
        )
        (asserts! (is-authorized-issuer tx-sender) err-not-authorized-issuer)
        (asserts! (and (>= competency-level u1) (<= competency-level u4)) err-invalid-credential)
        (asserts! (> (len skill-name) u0) err-invalid-credential)
        (asserts! (> (len training-program) u0) err-invalid-credential)
        
        ;; Check if prerequisites are met
        (asserts! (check-prerequisites skill-name apprentice) err-invalid-credential)
        
        ;; Create the credential record
        (map-set credentials
            { credential-id: credential-id }
            {
                apprentice: apprentice,
                issuer: tx-sender,
                skill-name: skill-name,
                training-program: training-program,
                competency-level: competency-level,
                completion-date: current-time,
                expiry-date: expiry-date,
                status: status-active,
                verification-hash: verification-hash,
                metadata-uri: metadata-uri,
                prerequisites-met: true,
                assessment-score: assessment-score
            }
        )
        
        ;; Mint the NFT
        (try! (nft-mint? apprenticeship-credential credential-id apprentice))
        
        ;; Update counters and progress
        (var-set credential-counter credential-id)
        (update-issuer-stats tx-sender)
        (update-apprentice-progress apprentice skill-name competency-level)
        
        (ok credential-id)
    )
)

;; Transfer credential to another wallet
(define-public (transfer-credential (credential-id uint) (sender principal) (recipient principal))
    (let
        (
            (credential-data (unwrap! (map-get? credentials { credential-id: credential-id }) err-not-found))
        )
        (asserts! (is-eq sender (get apprentice credential-data)) err-unauthorized)
        (asserts! (is-eq tx-sender sender) err-unauthorized)
        (asserts! (is-eq (get status credential-data) status-active) err-invalid-transfer)
        
        ;; Transfer the NFT
        (try! (nft-transfer? apprenticeship-credential credential-id sender recipient))
        
        ;; Update credential record
        (map-set credentials
            { credential-id: credential-id }
            (merge credential-data { apprentice: recipient })
        )
        
        (ok true)
    )
)

;; Register a new authorized credential issuer
(define-public (register-issuer
    (issuer principal)
    (organization-name (string-ascii 100))
    (contact-info (string-ascii 150))
    (accreditation-level uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-admin)) err-owner-only)
        (asserts! (is-none (map-get? authorized-issuers { issuer: issuer })) err-already-exists)
        (asserts! (> (len organization-name) u0) err-invalid-credential)
        
        (map-set authorized-issuers
            { issuer: issuer }
            {
                organization-name: organization-name,
                contact-info: contact-info,
                accreditation-level: accreditation-level,
                is-active: true,
                registered-date: burn-block-height,
                credentials-issued: u0
            }
        )
        
        (ok true)
    )
)

;; Revoke a credential
(define-public (revoke-credential (credential-id uint))
    (let
        (
            (credential-data (unwrap! (map-get? credentials { credential-id: credential-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get issuer credential-data)) err-unauthorized)
        (asserts! (is-eq (get status credential-data) status-active) err-invalid-credential)
        
        ;; Update status to revoked
        (map-set credentials
            { credential-id: credential-id }
            (merge credential-data { status: status-revoked })
        )
        
        (ok true)
    )
)

;; Verify a credential using verification code
(define-public (verify-credential (verification-code (string-ascii 32)) (credential-id uint))
    (let
        (
            (credential-data (unwrap! (map-get? credentials { credential-id: credential-id }) err-not-found))
        )
        ;; Create verification record
        (map-set credential-verification
            { verification-code: verification-code }
            {
                credential-id: credential-id,
                verified-by: tx-sender,
                verification-date: burn-block-height,
                is-valid: (is-credential-valid credential-id)
            }
        )
        
        (ok (is-credential-valid credential-id))
    )
)

;; Read-only functions

(define-read-only (get-credential-details (credential-id uint))
    (map-get? credentials { credential-id: credential-id })
)

(define-read-only (get-credential-owner (credential-id uint))
    (nft-get-owner? apprenticeship-credential credential-id)
)

(define-read-only (get-apprentice-credentials (apprentice principal))
    ;; Returns basic info - full implementation would use iteration
    (map-get? apprentice-progress { apprentice: apprentice, skill-area: "general" })
)

(define-read-only (is-authorized-issuer (issuer principal))
    (match (map-get? authorized-issuers { issuer: issuer })
        issuer-data (get is-active issuer-data)
        false
    )
)

(define-read-only (get-issuer-info (issuer principal))
    (map-get? authorized-issuers { issuer: issuer })
)

(define-read-only (get-credential-count)
    (var-get credential-counter)
)

(define-read-only (is-credential-valid (credential-id uint))
    (match (map-get? credentials { credential-id: credential-id })
        credential-data
        (and
            (is-eq (get status credential-data) status-active)
            (match (get expiry-date credential-data)
                expiry (> expiry burn-block-height)
                true
            )
        )
        false
    )
)

(define-read-only (get-verification-result (verification-code (string-ascii 32)))
    (map-get? credential-verification { verification-code: verification-code })
)

;; Private helper functions

(define-private (check-prerequisites (skill-name (string-ascii 100)) (apprentice principal))
    ;; Simplified prerequisite check - production would verify actual prerequisites
    true
)

(define-private (update-issuer-stats (issuer principal))
    (let
        (
            (issuer-data (unwrap-panic (map-get? authorized-issuers { issuer: issuer })))
        )
        (map-set authorized-issuers
            { issuer: issuer }
            (merge issuer-data {
                credentials-issued: (+ (get credentials-issued issuer-data) u1)
            })
        )
    )
)

(define-private (update-apprentice-progress (apprentice principal) (skill-name (string-ascii 100)) (level uint))
    (let
        (
            (skill-area-key (unwrap-panic (as-max-len? skill-name u50)))
            (current-progress (default-to
                { current-level: u0, credentials-earned: u0, last-updated: u0, total-training-hours: u0, mentor-assigned: none }
                (map-get? apprentice-progress { apprentice: apprentice, skill-area: skill-area-key })
            ))
        )
        (map-set apprentice-progress
            { apprentice: apprentice, skill-area: skill-area-key }
            (merge current-progress {
                current-level: (if (> level (get current-level current-progress)) level (get current-level current-progress)),
                credentials-earned: (+ (get credentials-earned current-progress) u1),
                last-updated: burn-block-height
            })
        )
    )
)

