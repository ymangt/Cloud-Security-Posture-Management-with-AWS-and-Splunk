# Cloud-Security-Posture-Management-with-AWS-and-Splunk

A comprehensive lab demonstrating Cloud Security Posture Management (CSPM) using an AWS EC2 instance, Prowler for security assessments, and Splunk for monitoring and visualization. This repository includes setup instructions, scan results, and a custom dashboard to analyze security compliance and misconfigurations.

## Overview

This project showcases the setup and security assessment of an AWS EC2 instance, integrated with Splunk for real-time monitoring and visualization. The lab leverages industry-standard tools to evaluate the security posture of a cloud environment, providing actionable insights through a dedicated dashboard.

## Setup and Execution

### Prerequisites
- An AWS account with Free Tier enabled.
- VMware Workstation Pro with a virtual machine (e.g., Ubuntu 20.04) configured as SIEM-Lab-VM.
- An SSH client (e.g., OpenSSH via Git Bash or PowerShell).
- Basic knowledge of AWS, Linux, and Splunk.

### Step-by-Step Guide
For detailed instructions, refer to [docs/setup-guide.md](docs/setup-guide.md). Key steps include:
1. **AWS Configuration**:
   - Create a key pair (`<key-pair-name>`) and a security group (`launch-wizard-2`) with SSH (port 22) and HTTP (port 80) access.
   - Launch an EC2 instance (`t3.micro`, Amazon Linux 2023 AMI) with the `ProwlerRole` IAM role in `us-east-2`.
2. **Prowler Installation and Scan**:
   - Install Prowler 5.11.0 on the EC2 instance and run a security scan to generate a JSON report.
3. **Splunk Integration**:
   - Set up Splunk on SIEM-Lab-VM, ingest the Prowler report, and create the "Cloud Security Posture Dashboard."
4. **Documentation**:
   - Capture a screenshot and export it as a PDF for submission.

## Results
The lab successfully identified security compliance and misconfigurations, visualized in the following deliverables:
- [Screenshot of Dashboard](lab-files/screenshots/cloud-dashboard.png)
- [PDF Report of Dashboard](lab-files/reports/cloud-report.pdf)

## Files
- `lab-files/screenshots/cloud-dashboard.png`: Visual proof of the "Cloud Security Posture Dashboard" with Compliance Status and Misconfigurations panels.
- `lab-files/reports/cloud-report.pdf`: Formal PDF export of the dashboard for detailed review.
- `lab-files/data/prowler-report.json` (optional): Sanitized raw Prowler scan results for transparency.
- `terraform/main.tf`: Terraform configuration for the EC2 instance, IAM role, and security group setup.
- `docs/architecture.md`: High-level architecture overview with a Mermaid diagram of the lab.
- `docs/setup-guide.md`: Step-by-step instructions to replicate the lab setup.

## Architecture
The lab architecture is detailed in [docs/architecture.md](docs/architecture.md), illustrating the flow from AWS to the EC2 instance with Prowler, and Splunk on the SIEM-Lab-VM.

## Contributors
- Youssef Elmanawy (ymangt)

## Acknowledgments
- AWS for providing the Free Tier and EC2 services.
- Prowler community for the open-source security tool.
- Splunk for the monitoring platform.

