# Setup Guide for Cloud Security Posture Management Lab

This guide provides step-by-step instructions to set up the Cloud Security Posture Management (CSPM) lab using AWS, Prowler, and Splunk. It replicates the environment used to assess an EC2 instance's security posture and visualize findings in a custom dashboard.

## Prerequisites

- **AWS Account**: Sign up at [aws.amazon.com](https://aws.amazon.com) and enable the Free Tier.
- **VMware Workstation Pro**: Installed on your host PC with a virtual machine (SIEM-Lab-VM) running Ubuntu 20.04 or later.
- **SSH Client**: Installed on your host PC (e.g., OpenSSH via Git Bash or PowerShell).
- **Basic Knowledge**: Familiarity with AWS, Linux command line, and Splunk basics.
- **Internet Access**: Required for AWS API calls and software downloads.

## Step-by-Step Instructions

### 1. Set Up AWS Environment
1. **Create a Key Pair**:
   - In the AWS Console, go to EC2 > Key Pairs > Create Key Pair.
   - Name: `cloud-security-key`.
   - Download `cloud-security-key.pem` and secure it (e.g., `chmod 400` on Linux or adjust permissions on Windows).

2. **Configure Security Group**:
   - Go to EC2 > Security Groups > Create Security Group.
   - Name: `launch-wizard-2`.
   - Inbound Rules:
     - Type: SSH, Port: 22, Source: Your public IP (e.g., `99.243.40.25/32`, check at whatismyip.com).
     - Type: HTTP, Port: 80, Source: `0.0.0.0/0`.
   - Outbound Rules: Allow all traffic (`0.0.0.0/0`).
   - Create and note the Security Group ID (e.g., `sg-05194b78fd83b7d4d`).

3. **Create IAM Role**:
   - Go to IAM > Roles > Create Role.
   - Select: AWS Service > EC2 > Next.
   - Attach Policy: `AmazonEC2ReadOnlyAccess`.
   - Role Name: `ProwlerRole`.
   - Create and note the Role ARN.

### 2. Launch EC2 Instance
1. **Launch Instance**:
   - Go to EC2 > Instances > Launch Instance.
   - AMI: Amazon Linux 2023 (e.g., `ami-06d53ad9c5c4da96d` in us-east-2).
   - Instance Type: `t3.micro`.
   - Key Pair: `cloud-security-key`.
   - Network: Default VPC, Subnet in `us-east-2c` (e.g., `subnet-0dc4c113d2d4da216`).
   - Security Group: `launch-wizard-2`.
   - Configure Instance Details: Enable IMDSv2 (required).
   - Add Storage: 8 GiB (default).
   - Tags: Key=Name, Value=Cloud-Security-VM.
   - Launch Instance and note the Instance ID (e.g., `i-05557392b2293e188`).

2. **Attach IAM Role**:
   - Go to EC2 > Instances > Select "Cloud-Security-VM" > Actions > Security > Modify IAM Role.
   - Attach `ProwlerRole` and save.

3. **Connect to Instance**:
   - On host PC, run: `ssh -i cloud-security-key.pem ec2-user@18.222.60.52`.

### 3. Install Prowler on EC2
1. **Update System**:
   - Run: `sudo dnf update -y`.

2. **Install Dependencies**:
   - Run: `sudo dnf install -y git python3 python3-pip`.

3. **Install Prowler**:
   - Run: `git clone https://github.com/prowler-cloud/prowler.git`.
   - Navigate: `cd prowler`.
   - Install: `sudo pip3 install -r requirements.txt`.
   - Configure: `sudo ./install-aws.sh`.

4. **Verify**:
   - Run: `./prowler-cli.py --version` (expect 5.11.0).

### 4. Run Prowler Scan
1. **Execute Scan**:
   - Run: `./prowler-cli.py aws -M json-asff -o /home/ec2-user/prowler-output/prowler-report.json --region us-east-2`.
   - Wait for completion (5-15 minutes).

2. **Download Report**:
   - On host PC, run: `scp -i cloud-security-key.pem ec2-user@18.222.60.52:/home/ec2-user/prowler-output/prowler-report.json C:/Users/yhman/Downloads/prowler-report.json`.

### 5. Set Up SIEM-Lab-VM
1. **Install Splunk**:
   - Download Splunk from [splunk.com](https://www.splunk.com) on host PC.
   - Transfer to SIEM-Lab-VM via shared folder or USB.
   - Install: Follow Splunk’s Ubuntu instructions (e.g., `dpkg -i splunk-*.deb`, start with `/opt/splunk/bin/splunk start`).

2. **Configure Splunk**:
   - Access: http://192.168.71.133:8000.
   - Set up admin user and index.

### 6. Integrate Prowler Report with Splunk
1. **Transfer Report**:
   - Move `prowler-report.json` to SIEM-Lab-VM (e.g., via shared folder: `cp /mnt/hgfs/DownloadsShare/prowler-report.json ~/`).

2. **Add Data Input**:
   - In Splunk, go to Settings > Data Inputs > Files & Directories > Add New.
   - Monitor: `/home/youssef/prowler-report.json` > Set sourcetype to `prowler_log`.

3. **Verify**:
   - Search: `index=main sourcetype=prowler_log`.

### 7. Create Dashboard
1. **Build Dashboard**:
   - Go to Dashboards > Create New > Name: "Cloud Security Posture Dashboard".
   - Add Panels:
     - Compliance Status: `index=main sourcetype=prowler_log | stats count(eval(Severity="CRITICAL")) as critical, count(eval(Severity="HIGH")) as high | eval total=critical+high | eval score=100-(critical/total*100)` > Single Value.
     - Misconfigurations: `index=main sourcetype=prowler_log | table FindingId Title` > Statistics Table.
   - Save.

2. **Capture Screenshot**:
   - On host PC, use Snipping Tool to capture the dashboard, save as `C:\Users\yhman\cloud-dashboard.png`.

3. **Generate PDF**:
   - Open in LibreOffice Draw, export as `C:\Users\yhman\cloud-report.pdf`.

### 8. Upload to GitHub
1. **Organize Files**:
   - Create structure: `lab-files/{screenshots,reports,data}, docs/, terraform/`.
   - Move files: `cloud-dashboard.png` to `lab-files/screenshots/`, `cloud-report.pdf` to `lab-files/reports/`.

2. **Upload**:
   - Go to GitHub, use "Add file" > "Upload files" for each path.
   - Commit with appropriate messages.

## Troubleshooting
- **EC2 Access Denied**: Check key permissions, security group.
- **Prowler Fails**: Ensure IAM role is attached, region is correct.
- **Splunk Issues**: Restart service, check file path.

## References
- AWS EC2: https://docs.aws.amazon.com/ec2/
- Prowler: https://github.com/prowler-cloud/prowler
- Splunk: https://docs.splunk.com
