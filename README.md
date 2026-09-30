# Java 3-Tier AWS Application

A Java web application built with Spring Boot and deployed on AWS using a 3-tier architecture.

The application provides:

- User registration
- User login
- Authenticated user access
- Logout
- MySQL database integration

The application is packaged as a WAR and deployed to Apache Tomcat 11 running on private EC2 instances behind an Application Load Balancer.

Amazon RDS for MySQL is used as the database tier.

## Project Objective

The objective of this project is to build and deploy a complete Java 3-tier application using modern Spring Boot development practices and AWS infrastructure.

The project demonstrates:

- Java 21
- Spring Boot
- Spring MVC
- Spring Security
- BCrypt password hashing
- Spring JDBC
- JSP/JSTL
- Apache Tomcat 11
- MySQL
- Terraform
- Amazon EC2
- Auto Scaling Group
- Application Load Balancer
- Amazon RDS
- Amazon S3
- AWS Systems Manager
- AWS Secrets Manager
- IAM
- VPC and private networking

## Architecture

The application follows a 3-tier architecture.

```text
                         Internet
                            |
                            v
                    +---------------+
                    | Public ALB    |
                    | HTTP :80      |
                    +-------+-------+
                            |
                       HTTP :8080
                            |
             +--------------+--------------+
             |                             |
             v                             v
      +--------------+              +--------------+
      | EC2 / Tomcat |              | EC2 / Tomcat |
      | Private      |              | Private      |
      | Subnet / AZ  |              | Subnet / AZ  |
      +------+-------+              +------+-------+
             |                             |
             +--------------+--------------+
                            |
                       MySQL :3306
                            |
                            v
                    +---------------+
                    | RDS MySQL     |
                    | Private       |
                    +---------------+


Terraform
    |
    +----> VPC / Subnets / Routing
    +----> ALB
    +----> Auto Scaling Group
    +----> EC2 Launch Template
    +----> RDS
    +----> Security Groups
    +----> IAM

S3
 |
 +----> Application WAR artifact
             |
             v
          EC2/Tomcat

Secrets Manager
 |
 +----> RDS database credentials
             |
             v
          EC2/Tomcat

SSM
 |
 +----> EC2 administration

NAT Gateway
 |
 +----> Private subnet outbound access


## Technology Stack

### Application

| Technology | Purpose |
|---|---|
| Java 21 | Application runtime |
| Spring Boot 4.1.1 | Application framework |
| Spring MVC | Web layer |
| Spring Security | Authentication and authorization |
| Spring JDBC | Database access |
| BCrypt | Password hashing |
| JSP/JSTL | Web views |
| Maven | Build and dependency management |
| WAR | Application packaging |
| Apache Tomcat 11 | Application server |
| MySQL | Relational database |

### AWS

| AWS Service | Purpose |
|---|---|
| Amazon VPC | Network isolation |
| Public Subnets | Public-facing resources |
| Private Subnets | Application and database resources |
| Internet Gateway | Internet connectivity |
| NAT Gateway | Outbound internet access from private subnets |
| Application Load Balancer | Traffic distribution |
| Amazon EC2 | Application servers |
| Auto Scaling Group | Application availability and self-healing |
| Amazon RDS | Managed MySQL database |
| Amazon S3 | WAR artifact storage |
| AWS Systems Manager | EC2 administration |
| AWS Secrets Manager | Database credential management |
| IAM | Access control |
| Security Groups | Network access control |
| Terraform | Infrastructure as Code |


## Project Structure

```text
Java-3Tier-AWS-Project/
|
+-- Java-Login-App/
|   |
|   +-- src/
|   |   |
|   |   +-- main/
|   |       |
|   |       +-- java/com/devopsrealtime/javaloginapp/
|   |       |   |
|   |       |   +-- config/
|   |       |   |   +-- WebConfig.java
|   |       |   |
|   |       |   +-- controller/
|   |       |   |   +-- HomeController.java
|   |       |   |   +-- LoginController.java
|   |       |   |   +-- RegisterController.java
|   |       |   |   +-- UserController.java
|   |       |   |
|   |       |   +-- model/
|   |       |   |   +-- Employee.java
|   |       |   |
|   |       |   +-- repository/
|   |       |   |   +-- EmployeeRepository.java
|   |       |   |
|   |       |   +-- service/
|   |       |       +-- EmployeeService.java
|   |       |       +-- EmployeeUserDetailsService.java
|   |       |
|   |       +-- SecurityConfig.java
|   |       +-- JavaloginappApplication.java
|   |       +-- ServletInitializer.java
|   |
|   +-- pom.xml
|
+-- infrastructure/
|   +-- main.tf
|   +-- provider.tf
|   +-- variables.tf
|   +-- outputs.tf
|   +-- alb.tf
|   +-- asg.tf
|   +-- ec2.tf
|   +-- iam.tf
|   +-- rds.tf
|   +-- security.tf
|
+-- README.md

## Application Flow

### Registration Flow

```text
Browser
   |
   v
ALB
   |
   v
Tomcat / Spring Boot
   |
   v
RegisterController
   |
   v
EmployeeService
   |
   v
EmployeeRepository
   |
   v
RDS MySQL


## AWS Infrastructure

The AWS environment is designed as a 3-tier architecture inside a VPC.

### Network Layer

The VPC contains:

- Public subnets
- Private application subnets
- Private database subnets
- Internet Gateway
- NAT Gateway
- Route tables

The public subnet contains the internet-facing Application Load Balancer.

The application EC2 instances are placed in private subnets.

The RDS MySQL database is placed in private database subnets.

### Application Layer

The application tier consists of:

- Application Load Balancer
- Auto Scaling Group
- EC2 instances
- Apache Tomcat 11
- Spring Boot application

The Auto Scaling Group maintains the desired number of application instances.

Current configuration:

```text
Minimum instances: 2
Desired instances: 2
Maximum instances: 6

## Terraform Infrastructure

Terraform is used to provision and manage the AWS infrastructure.

### Terraform Files

```text
infrastructure/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── alb.tf
├── asg.tf
├── ec2.tf
├── iam.tf
├── rds.tf
└── security.tf
```

## CI/CD Pipeline

GitHub Actions is used to automate application CI/CD and Terraform infrastructure validation and deployment.

### Application CI/CD

The Java application CI/CD workflow is defined in:

```text
.github/workflows/application-ci.yml
```

The workflow performs the following steps:

1. Checkout source code
2. Set up Java 21
3. Run Maven tests
4. Build the WAR file
5. Upload the WAR artifact
6. Authenticate to AWS using GitHub OIDC
7. Upload the application WAR to Amazon S3
8. Deploy the selected application version to EC2 using AWS Systems Manager
9. Verify deployment success on all application instances

Application versions are deployed using version tags such as:

```text
v1.0
v2.0
v3.0
```

Versioned application artifacts are stored in:

```text
s3://java-3tier-app-deploy-089783390772/releases/<version>/javaloginapp.war
```

The current application artifact is stored at:

```text
s3://java-3tier-app-deploy-089783390772/current/javaloginapp.war
```

### Terraform CI

The Terraform CI workflow is defined in:

```text
.github/workflows/terraform-ci.yml
```

It performs:

1. Checkout source code
2. Set up Terraform
3. Authenticate to AWS using GitHub OIDC
4. Verify AWS identity
5. Run Terraform format check
6. Run Terraform init
7. Run Terraform validate
8. Run Terraform plan

### Terraform Apply

The Terraform deployment workflow is defined in:

```text
.github/workflows/terraform-apply.yml
```

It can be manually triggered using GitHub Actions.

The workflow performs:

1. Checkout source code
2. Set up Terraform
3. Authenticate to AWS using GitHub OIDC
4. Initialize Terraform
5. Generate a Terraform plan
6. Apply the Terraform plan

### GitHub OIDC Authentication

GitHub Actions uses AWS IAM OIDC authentication instead of storing long-lived AWS access keys in GitHub.

Separate IAM roles are used for:

- Terraform plan
- Terraform apply
- Java application deployment

### Terraform Remote State

Terraform state is stored remotely in Amazon S3.

```text
S3 Bucket:
java-3tier-terraform-state-089783390772

State Key:
java-3tier-app/terraform.tfstate

Region:
us-east-1
```

The S3 backend is configured with encryption and state locking.

### CI/CD Verification

The complete CI/CD process was successfully verified.

Application version `v3.0` was deployed through GitHub Actions.

The deployment completed successfully on both application EC2 instances.

The Application Load Balancer returned:

```text
Application Version: v3.0
```

This confirms the end-to-end flow:

```text
GitHub
   |
   v
GitHub Actions
   |
   +--------------------+
   |                    |
   v                    v
Java CI/CD         Terraform CI/CD
   |                    |
   v                    v
Build WAR          Terraform Plan/Apply
   |
   v
Amazon S3
   |
   v
AWS Systems Manager
   |
   v
EC2 / Tomcat
   |
   v
Application Load Balancer
   |
   v
Users
```

## Testing and Verification

The application and AWS infrastructure were tested at multiple levels.

### Application Testing

The following application functions were tested:

- Home page
- User registration
- Duplicate username handling
- Login with valid credentials
- Login with invalid credentials
- Authenticated user page
- Logout
- CSRF protection
- BCrypt password authentication

### AWS Testing

The following AWS components were verified:

- Application Load Balancer
- ALB target group
- EC2 instances
- Auto Scaling Group
- ASG self-healing
- RDS MySQL
- Security Groups
- IAM permissions
- S3 deployment artifact
- Systems Manager
- Secrets Manager
- Terraform configuration

### Final EC2 State

The final environment contains two running application instances belonging to:

```text
java-3tier-app-asg


The two application instances were verified as healthy targets in the ALB target group.

### Final RDS State

Database: java-3tier-app-mysql
Engine: MySQL
Port: 3306
Status: Available
Publicly Accessible: False

### Final Terraform State

The final Terraform plan reported:

No changes. Your infrastructure matches the configuration.

This confirms that Terraform detected no differences between the Terraform configuration and the deployed infrastructure during the final verification.

---

## Troubleshooting

Several issues were encountered and resolved during development.

### JSP Page Access

The application was configured to render JSP pages through Spring MVC using the JSP view resolver.

### CSRF Protection

POST requests require a valid CSRF token because Spring Security CSRF protection is enabled.

CSRF tokens were added to the application forms.

### Database Authentication

Database authentication was configured using the dedicated application database user.

### BCrypt Password Authentication

User passwords are stored using BCrypt rather than plaintext passwords.

### EC2 Deployment

The application WAR was uploaded to S3 and deployed to the application instances running Apache Tomcat 11.

The application was then tested through the public Application Load Balancer.

---

## Security Checklist

The following security practices are implemented:

- Passwords stored using BCrypt
- Parameterized SQL queries
- Spring Security authentication
- CSRF protection
- RDS not publicly accessible
- Application EC2 instances in private subnets
- RDS in private networking
- ALB as the public application entry point
- EC2 port 8080 restricted to the ALB security group
- RDS port 3306 restricted to the application security group
- S3 access restricted through IAM
- Secrets Manager access restricted through IAM
- Systems Manager used for EC2 administration
- Database credentials not hardcoded in application source code
- Encrypted EC2 root volume

---

## GitHub Preparation

Before pushing the project to GitHub, sensitive and generated files should remain excluded.

The following should not be committed:

.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
target/
*.war
*.pem
.env
credentials
secrets

Terraform state files can contain sensitive infrastructure information and are therefore excluded through the root .gitignore.

---

## Future Improvements

Possible future improvements include:

- HTTPS using AWS Certificate Manager
- Route 53 DNS
- CloudWatch dashboards and alarms
- Centralized application logging
- Blue/green deployment
- Rolling deployments
- Automated application testing
- RDS Multi-AZ
- Containerized deployment

These are future improvements and are not presented as currently implemented features.

---

## Final Project Status

The Java 3-Tier AWS application was successfully deployed, tested, and verified on AWS.

After completing the deployment and functional testing, the AWS infrastructure was intentionally destroyed to minimize ongoing AWS costs. The Terraform configuration, CI/CD workflows, application source code, and documentation remain in the repository so the complete environment can be recreated when required.

### Application

Java 21
Spring Boot 4.1.1
Spring MVC
Spring Security
BCrypt
Spring JDBC
JSP/JSTL
Tomcat 11
MySQL

### AWS Services Used

VPC
Public/Private Subnets
Internet Gateway
NAT Gateway
Application Load Balancer
Auto Scaling Group
EC2
RDS MySQL
S3
Systems Manager
Secrets Manager
IAM
Security Groups
Terraform

### Deployment Verification

The application was successfully verified before infrastructure cleanup.

Verified functionality included:

- Application deployment through the CI/CD pipeline
- EC2 application instances running behind the Application Load Balancer
- Target group health checks
- User registration
- User login
- User logout
- MySQL database connectivity
- Spring Security authentication
- BCrypt password authentication
- SSM-based deployment
- Terraform infrastructure deployment
- GitHub Actions CI/CD workflows

### Final Architecture Used During Testing

                    INTERNET
                       |
                       v
                +-------------+
                | Public ALB  |
                | HTTP :80    |
                +------+------+
                       |
                  HTTP :8080
                       |
            +----------+----------+
            |                     |
            v                     v
     +-------------+       +-------------+
     | EC2/Tomcat  |       | EC2/Tomcat  |
     | Private     |       | Private     |
     +------+------+       +------+------+
            |                     |
            +----------+----------+
                       |
                  MySQL :3306
                       |
                       v
                +-------------+
                | RDS MySQL   |
                | Private     |
                +-------------+

### Final Application Flow Used During Testing

User
  |
  v
ALB
  |
  v
Tomcat
  |
  v
Spring Boot
  |
  +--> Controller
          |
          v
       Service
          |
          v
      Repository
          |
          v
       MySQL

### Current AWS State

The following AWS infrastructure and resources were intentionally removed after successful testing to minimize ongoing AWS costs:

- EC2 instances
- Auto Scaling Group
- Application Load Balancer
- Target Group
- NAT Gateway
- Elastic IP
- RDS database instance
- Project VPC and associated subnets
- Project security groups
- Project route tables
- Old React CodePipeline resources
- Old React CodeBuild project
- Old React CodeDeploy application
- Old React ECR repository
- Old React CodePipeline artifact bucket
- Old React CloudWatch log groups

The default AWS VPC was retained.

### Data and Project Preservation

The following project resources were retained:

- Terraform source configuration
- GitHub Actions workflows
- GitHub OIDC/IAM configuration used by the CI/CD workflows
- Terraform remote state S3 bucket
- Java application deployment S3 bucket
- Final RDS snapshot for possible future database restoration
- GitHub repository and project documentation

The final RDS snapshot was created before deleting the RDS instance and is retained separately from the destroyed live infrastructure.

### Important Note

The previously used ALB endpoint is no longer active because the AWS infrastructure was intentionally destroyed after testing.

The project can be recreated by using the Terraform configuration and the existing CI/CD workflows.

### Project Completion

The project is now complete and suitable for:

- GitHub publication
- Architecture presentation
- Technical documentation review
- AWS/DevOps interview preparation
- Terraform and CI/CD demonstration
- Future infrastructure recreation and testing
