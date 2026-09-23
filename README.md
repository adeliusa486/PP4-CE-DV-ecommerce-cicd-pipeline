# Serverless CI/CD Automation Pipeline

This project implements an enterprise-grade Continuous Integration and Continuous Deployment pipeline for an event-driven, serverless e-commerce backend on Amazon Web Services. The primary focus of this repository is to demonstrate automated GitOps workflows, infrastructure security scanning, and zero-touch deployments.

## Pipeline Architecture

The automation workflow is managed via GitHub Actions and consists of the following deployment stages:

* Continuous Integration: Automated execution of Python unit tests using pytest to validate microservice business logic before deployment.
* Infrastructure Security Scanning: Static code analysis of the Terraform configuration using tfsec to identify potential cloud security vulnerabilities.
* Artifact Packaging: Automated compression and versioning of the Python AWS Lambda deployment packages.
* Continuous Deployment: Automated execution of Terraform infrastructure as code to provision and update the AWS API Gateway, DynamoDB tables, EventBridge buses, and Step Functions state machines.

## Core Engineering Concepts

### GitOps and Automation
All infrastructure and application changes are driven strictly through version control. Manual interventions and terminal deployments are eliminated, ensuring all deployments are reproducible, auditable, and secure.

### Shift-Left Security
By integrating infrastructure security scanning directly into the deployment pipeline, cloud misconfigurations are caught and blocked before they reach the live environment.

### Immutable Infrastructure
The pipeline relies on Terraform to maintain a strict state of the AWS environment. The CI/CD process ensures that the live cloud infrastructure exactly matches the committed repository code.

## File Structure

```text
.
|-- .github/
|   |-- workflows/
|-- services/
|   |-- inventory-service/
|   |-- notification-service/
|   |-- order-service/
|   |-- payment-service/
|-- terraform/
|   |-- environments/
|   |-- modules/
```

## Deployment Requirements

To operate this pipeline, the following secrets must be configured in the GitHub repository environment:
* AWS Access Key ID
* AWS Secret Access Key
