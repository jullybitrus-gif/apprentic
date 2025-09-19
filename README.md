# Apprentic - On-Chain Apprenticeship Records 🗂️

A blockchain-based NFT credential system for tracking apprenticeship training and professional development on the Stacks blockchain using Clarity smart contracts.

## Overview

Apprentic provides a decentralized, tamper-proof platform for:
- Creating and managing apprenticeship programs
- Issuing verifiable NFT credentials for completed training modules
- Tracking skill development and competency progression
- Building a permanent record of professional achievements
- Enabling employers to verify candidate qualifications instantly

## Features

### Core Functionality
- **NFT Credentials**: Each completed training module or milestone is issued as a unique NFT
- **Skill Registry**: Comprehensive catalog of skills, competencies, and training programs
- **Progress Tracking**: Monitor apprentice advancement through structured learning paths
- **Verification System**: Instant verification of credentials by employers and institutions
- **Mentor Management**: Tools for trainers and mentors to assess and certify progress

### Smart Contract Architecture
- **Apprenticeship Records Contract**: Manages NFT creation, ownership, and metadata
- **Skills Registry Contract**: Defines available skills, requirements, and validation criteria

## Technical Specifications

### NFT Structure
- **Token ID**: Unique identifier for each credential
- **Metadata**: Training program details, completion date, skill level achieved
- **Apprentice Address**: Blockchain address of the credential holder
- **Issuer**: Authorized training organization or mentor
- **Verification Status**: Validation state and authenticity proof

### Skills Framework
- **Skill Categories**: Organized by trade, profession, or industry
- **Competency Levels**: Beginner, Intermediate, Advanced, Expert
- **Prerequisites**: Required prior learning or experience
- **Assessment Criteria**: Standards for credential issuance

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Git
- Stacks wallet for blockchain interaction

### Installation
```bash
git clone <repository-url>
cd apprentic
npm install
```

### Running Tests
```bash
npm test
```

### Contract Validation
```bash
clarinet check
```

## Usage

### For Training Organizations
1. Register as an authorized credential issuer
2. Define training programs and skill requirements
3. Assess apprentice progress and issue NFT credentials
4. Maintain records of all issued certifications

### For Apprentices
1. Enroll in approved training programs
2. Complete required modules and assessments
3. Receive NFT credentials upon successful completion
4. Build a verifiable portfolio of skills and achievements

### For Employers
1. Verify candidate credentials instantly on-chain
2. Access detailed training history and skill assessments
3. Confirm authenticity of all claimed qualifications
4. Make informed hiring decisions based on verified data

## Contract Functions

### Public Functions
- `mint-credential`: Issue new NFT credential to apprentice
- `register-skill`: Add new skill to the registry
- `update-progress`: Record learning milestone completion
- `verify-credential`: Validate authenticity of NFT credential
- `transfer-credential`: Move credential between wallets

### Read-Only Functions
- `get-credential-details`: Retrieve full credential information
- `get-apprentice-credentials`: List all credentials for an apprentice
- `get-skill-info`: Access skill definition and requirements
- `is-authorized-issuer`: Verify credential issuing authority
- `get-training-progress`: Check apprentice advancement status

## Data Security

- **Immutable Records**: All credentials are permanently recorded on blockchain
- **Cryptographic Verification**: Each NFT includes tamper-proof validation
- **Access Control**: Only authorized issuers can create new credentials
- **Privacy Protection**: Personal data handled according to best practices

## Use Cases

### Traditional Trades
- Electrical apprenticeships
- Plumbing certifications  
- Construction skills development
- Manufacturing competencies

### Modern Professions
- Software development bootcamps
- Digital marketing certifications
- Healthcare training programs
- Financial services qualifications

### Educational Institutions
- Vocational school partnerships
- University skill certificates
- Professional development courses
- Industry collaboration programs

## Benefits

### For Apprentices
- **Portable Credentials**: Skills verified regardless of employer changes
- **Career Advancement**: Clear pathway to professional development
- **Recognition**: Public acknowledgment of achievements and competencies
- **Fraud Prevention**: Impossible to fake or duplicate credentials

### For Employers
- **Instant Verification**: No delays in credential authentication
- **Detailed Insights**: Access to comprehensive training history
- **Quality Assurance**: Confidence in candidate qualifications
- **Reduced Costs**: Eliminate manual verification processes

### For Training Organizations
- **Brand Protection**: Prevent credential forgery and misuse
- **Program Tracking**: Monitor effectiveness of training initiatives
- **Alumni Network**: Maintain connection with former apprentices
- **Industry Recognition**: Establish reputation for quality training

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Open an issue on GitHub
- Contact the development team
- Check the documentation

---

**Apprentic - Building the Future of Verified Professional Development** 🗂️
