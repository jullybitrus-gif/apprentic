;; Skills Registry Contract - Skill Definition and Validation
;; This contract manages skill definitions, requirements, and validation criteria
;; for apprenticeship programs and professional development.

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-found (err u201))
(define-constant err-unauthorized (err u202))
(define-constant err-invalid-skill (err u203))
(define-constant err-already-exists (err u204))
(define-constant err-invalid-category (err u205))
(define-constant err-prerequisite-not-met (err u206))

;; Industry Categories
(define-constant category-construction u1)
(define-constant category-manufacturing u2)
(define-constant category-healthcare u3)
(define-constant category-technology u4)
(define-constant category-finance u5)
(define-constant category-trades u6)
(define-constant category-general u7)

;; Difficulty Levels
(define-constant difficulty-basic u1)
(define-constant difficulty-intermediate u2)
(define-constant difficulty-advanced u3)
(define-constant difficulty-expert u4)
(define-constant difficulty-master u5)

;; Data Variables
(define-data-var skill-counter uint u0)
(define-data-var contract-admin principal tx-sender)
(define-data-var registry-version uint u1)

;; Data Maps
(define-map skills-catalog
    { skill-id: uint }
    {
        skill-name: (string-ascii 100),
        industry-category: uint,
        difficulty-level: uint,
        description: (string-utf8 500),
        minimum-hours: uint,
        assessment-required: bool,
        practical-component: bool,
        theory-component: bool,
        created-by: principal,
        created-date: uint,
        is-active: bool
    }
)

(define-map skill-prerequisites
    { skill-id: uint, prerequisite-index: uint }
    {
        required-skill-id: uint,
        minimum-competency: uint,
        is-mandatory: bool
    }
)

(define-map skill-pathways
    { pathway-id: uint }
    {
        pathway-name: (string-ascii 100),
        industry-focus: uint,
        skill-sequence: (list 20 uint),
        total-duration: uint,
        certification-authority: principal,
        pathway-description: (string-utf8 300),
        is-accredited: bool
    }
)

(define-map training-programs
    { program-id: uint }
    {
        program-name: (string-ascii 100),
        provider-organization: principal,
        skills-covered: (list 10 uint),
        duration-hours: uint,
        cost: uint,
        delivery-method: (string-ascii 50),
        certification-level: uint,
        enrollment-capacity: uint,
        current-enrollments: uint
    }
)

(define-map competency-standards
    { skill-id: uint, level: uint }
    {
        performance-criteria: (string-utf8 400),
        assessment-methods: (string-ascii 200),
        evidence-requirements: (string-utf8 300),
        evaluation-rubric: (string-ascii 150),
        passing-threshold: uint
    }
)

(define-map industry-standards
    { category: uint }
    {
        governing-body: (string-ascii 100),
        compliance-requirements: (string-utf8 400),
        update-frequency: uint,
        last-updated: uint,
        certification-validity: uint
    }
)

;; Public Functions

;; Register a new skill in the catalog
(define-public (register-skill
    (skill-name (string-ascii 100))
    (industry-category uint)
    (difficulty-level uint)
    (description (string-utf8 500))
    (minimum-hours uint)
    (assessment-required bool)
    (practical-component bool)
    (theory-component bool))
    (let
        (
            (skill-id (+ (var-get skill-counter) u1))
        )
        (asserts! (is-eq tx-sender (var-get contract-admin)) err-owner-only)
        (asserts! (and (>= industry-category u1) (<= industry-category u7)) err-invalid-category)
        (asserts! (and (>= difficulty-level u1) (<= difficulty-level u5)) err-invalid-skill)
        (asserts! (> (len skill-name) u0) err-invalid-skill)
        (asserts! (> minimum-hours u0) err-invalid-skill)
        
        ;; Create skill record
        (map-set skills-catalog
            { skill-id: skill-id }
            {
                skill-name: skill-name,
                industry-category: industry-category,
                difficulty-level: difficulty-level,
                description: description,
                minimum-hours: minimum-hours,
                assessment-required: assessment-required,
                practical-component: practical-component,
                theory-component: theory-component,
                created-by: tx-sender,
                created-date: burn-block-height,
                is-active: true
            }
        )
        
        ;; Update counter
        (var-set skill-counter skill-id)
        
        (ok skill-id)
    )
)

;; Add prerequisite for a skill
(define-public (add-skill-prerequisite
    (skill-id uint)
    (required-skill-id uint)
    (minimum-competency uint)
    (is-mandatory bool))
    (let
        (
            (skill-data (unwrap! (map-get? skills-catalog { skill-id: skill-id }) err-not-found))
            (prerequisite-index (get-next-prerequisite-index skill-id))
        )
        (asserts! (is-eq tx-sender (var-get contract-admin)) err-owner-only)
        (asserts! (is-some (map-get? skills-catalog { skill-id: required-skill-id })) err-not-found)
        (asserts! (and (>= minimum-competency u1) (<= minimum-competency u4)) err-invalid-skill)
        
        ;; Add prerequisite
        (map-set skill-prerequisites
            { skill-id: skill-id, prerequisite-index: prerequisite-index }
            {
                required-skill-id: required-skill-id,
                minimum-competency: minimum-competency,
                is-mandatory: is-mandatory
            }
        )
        
        (ok true)
    )
)

;; Create a learning pathway
(define-public (create-pathway
    (pathway-name (string-ascii 100))
    (industry-focus uint)
    (skill-sequence (list 20 uint))
    (total-duration uint)
    (pathway-description (string-utf8 300)))
    (let
        (
            (pathway-id (+ (get-pathway-count) u1))
        )
        (asserts! (is-eq tx-sender (var-get contract-admin)) err-owner-only)
        (asserts! (and (>= industry-focus u1) (<= industry-focus u7)) err-invalid-category)
        (asserts! (> (len pathway-name) u0) err-invalid-skill)
        (asserts! (> (len skill-sequence) u0) err-invalid-skill)
        (asserts! (validate-skill-sequence skill-sequence) err-invalid-skill)
        
        ;; Create pathway record
        (map-set skill-pathways
            { pathway-id: pathway-id }
            {
                pathway-name: pathway-name,
                industry-focus: industry-focus,
                skill-sequence: skill-sequence,
                total-duration: total-duration,
                certification-authority: tx-sender,
                pathway-description: pathway-description,
                is-accredited: false
            }
        )
        
        (ok pathway-id)
    )
)

;; Register a training program
(define-public (register-training-program
    (program-name (string-ascii 100))
    (skills-covered (list 10 uint))
    (duration-hours uint)
    (cost uint)
    (delivery-method (string-ascii 50))
    (certification-level uint)
    (enrollment-capacity uint))
    (let
        (
            (program-id (+ (get-program-count) u1))
        )
        (asserts! (> (len program-name) u0) err-invalid-skill)
        (asserts! (> (len skills-covered) u0) err-invalid-skill)
        (asserts! (> duration-hours u0) err-invalid-skill)
        (asserts! (and (>= certification-level u1) (<= certification-level u4)) err-invalid-skill)
        
        ;; Validate all skills exist
        (asserts! (validate-skill-sequence skills-covered) err-invalid-skill)
        
        ;; Create program record
        (map-set training-programs
            { program-id: program-id }
            {
                program-name: program-name,
                provider-organization: tx-sender,
                skills-covered: skills-covered,
                duration-hours: duration-hours,
                cost: cost,
                delivery-method: delivery-method,
                certification-level: certification-level,
                enrollment-capacity: enrollment-capacity,
                current-enrollments: u0
            }
        )
        
        (ok program-id)
    )
)

;; Define competency standards for a skill level
(define-public (set-competency-standard
    (skill-id uint)
    (level uint)
    (performance-criteria (string-utf8 400))
    (assessment-methods (string-ascii 200))
    (evidence-requirements (string-utf8 300))
    (passing-threshold uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-admin)) err-owner-only)
        (asserts! (is-some (map-get? skills-catalog { skill-id: skill-id })) err-not-found)
        (asserts! (and (>= level u1) (<= level u4)) err-invalid-skill)
        (asserts! (and (>= passing-threshold u1) (<= passing-threshold u100)) err-invalid-skill)
        
        ;; Set competency standard
        (map-set competency-standards
            { skill-id: skill-id, level: level }
            {
                performance-criteria: performance-criteria,
                assessment-methods: assessment-methods,
                evidence-requirements: evidence-requirements,
                evaluation-rubric: "standard",
                passing-threshold: passing-threshold
            }
        )
        
        (ok true)
    )
)

;; Read-only functions

(define-read-only (get-skill-info (skill-id uint))
    (map-get? skills-catalog { skill-id: skill-id })
)

(define-read-only (get-skill-prerequisites (skill-id uint))
    ;; Returns first prerequisite - full implementation would return all
    (map-get? skill-prerequisites { skill-id: skill-id, prerequisite-index: u1 })
)

(define-read-only (get-pathway-info (pathway-id uint))
    (map-get? skill-pathways { pathway-id: pathway-id })
)

(define-read-only (get-program-info (program-id uint))
    (map-get? training-programs { program-id: program-id })
)

(define-read-only (get-competency-standard (skill-id uint) (level uint))
    (map-get? competency-standards { skill-id: skill-id, level: level })
)

(define-read-only (get-industry-standards (category uint))
    (map-get? industry-standards { category: category })
)

(define-read-only (get-skill-count)
    (var-get skill-counter)
)

(define-read-only (is-skill-active (skill-id uint))
    (match (map-get? skills-catalog { skill-id: skill-id })
        skill-data (get is-active skill-data)
        false
    )
)

(define-read-only (check-skill-prerequisites (apprentice principal) (skill-id uint))
    ;; Simplified check - production would verify actual credentials
    true
)

;; Private helper functions

(define-private (validate-skill-sequence (skills (list 20 uint)))
    ;; Simplified validation - checks if first skill exists
    (match (element-at skills u0)
        first-skill (is-some (map-get? skills-catalog { skill-id: first-skill }))
        false
    )
)

(define-private (get-next-prerequisite-index (skill-id uint))
    ;; Simplified - returns u1 for demo, production would track actual indexes
    u1
)

(define-private (get-pathway-count)
    ;; Simplified - returns skill counter as proxy, production would have separate counter
    (var-get skill-counter)
)

(define-private (get-program-count)
    ;; Simplified - returns skill counter as proxy, production would have separate counter
    (var-get skill-counter)
)

