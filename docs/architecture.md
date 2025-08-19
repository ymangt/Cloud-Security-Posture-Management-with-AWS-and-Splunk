# Architecture Overview for Cloud Security Posture Management Lab

This document outlines the architecture of the Cloud Security Posture Management (CSPM) lab, which leverages AWS, Prowler, and Splunk to assess and monitor the security posture of an EC2 instance. The design integrates cloud infrastructure with security tools for compliance checking and visualization.

## Components

- **AWS EC2 Instance ("Cloud-Security-VM")**:
  - **Instance ID**: `i-05557392b2293e188`
  - **Region**: `us-east-2`
  - **Public IP**: `18.222.60.52`
  - **Private IP**: `172.31.34.64`
  - **AMI**: `ami-06d53ad9c5c4da96d` (Amazon Linux 2023)
  - **Instance Type**: `t3.micro`
  - **Key Pair**: `cloud-security-key`
  - **IAM Role**: `ProwlerRole` with `AmazonEC2ReadOnlyAccess` policy
  - **Security Group**: `launch-wizard-2` (ports 22 and 80 inbound, all outbound)
  - **Purpose**: Hosts the Prowler security scanning tool and serves as the target for compliance assessment.

- **Prowler**:
  - **Version**: 5.11.0
  - **Role**: Performs security assessments on the EC2 instance and AWS account, generating findings in AWS Security Finding Format (ASFF).
  - **Output**: JSON report (`prowler-report.json`) stored on the EC2 instance and transferred to SIEM-Lab-VM.

- **Splunk (on SIEM-Lab-VM)**:
  - **IP**: `192.168.71.133`
  - **Role**: Ingests the Prowler report, indexes it as `sourcetype=prowler_log`, and visualizes findings in a custom dashboard.
  - **Dashboard**: "Cloud Security Posture Dashboard" with Compliance Status and Misconfigurations panels.

## Architecture Diagram
graph TD
    A[Internet] --> B[AWS Cloud (us-east-2)]
    B --> C[EC2 Instance: Cloud-Security-VM (18.222.60.52)]
    C --> D[Prowler 5.11.0]
    D --> E[Scans EC2 and AWS account]
    D --> F[Generates prowler-report.json]
    C --> G[SIEM-Lab-VM (192.168.71.133)]
    G --> H[Splunk]
    H --> I[Ingests prowler-report.json]
    H --> J[Displays Cloud Security Posture Dashboard]


## Data Flow
1. **Setup**: The EC2 instance is launched with an IAM role (`ProwlerRole`) and a security group (`launch-wizard-2`) allowing SSH (port 22) and HTTP (port 80) access.
2. **Scanning**: Prowler runs on the EC2 instance, querying AWS APIs to assess compliance (e.g., FMS and VPC configurations) and produces a JSON report.
3. **Transfer**: The report is transferred from EC2 to SIEM-Lab-VM via shared folders or email.
4. **Analysis**: Splunk on SIEM-Lab-VM indexes the report, enabling the creation of the dashboard to visualize compliance status and misconfigurations.

## Key Considerations
- **Security**: The IAM role restricts Prowler to read-only EC2 access, minimizing risk. Sensitive data (e.g., ARNs) is sanitized in the repository.
- **Scalability**: The `t3.micro` instance is cost-effective for this lab but may need upgrading for larger scans.
- **Monitoring**: IMDSv2 is required, ensuring secure metadata access.

## References
- AWS EC2 Documentation: https://docs.aws.amazon.com/ec2/
- Prowler GitHub: https://github.com/prowler-cloud/prowler
- Splunk Documentation: https://docs.splunk.com
