#  DevOps CI/CD Pipeline

A production-oriented DevOps/GitOps project that automates the application delivery lifecycle from source code to deployment on Amazon EKS.

The project implements a **Continuous Integration (CI)** workflow using Jenkins and a **GitOps-based Continuous Deployment (CD)** workflow using Argo CD.

---

## 📌 Project Overview

The objective of this project is to build an automated and reliable software delivery pipeline using modern DevOps practices.

The pipeline automates:

* Source code management with GitHub
* Docker image building
* Container image storage using Amazon ECR
* Kubernetes configuration management using Kustomize
* Continuous Integration using Jenkins
* GitOps-based Continuous Deployment using Argo CD
* Container orchestration using Amazon EKS
* Infrastructure provisioning using Terraform

### End-to-End Flow

```text
GitHub
   │
   │ Source Code
   ▼
Jenkins
   │
   ├── Checkout
   ├── Docker Build
   ├── ECR Authentication
   ├── Push Image to ECR
   ├── Update Kubernetes Image Tag
   ├── Git Commit
   └── Git Push
   │
   ▼
GitHub
   │
   │ GitOps Change
   ▼
Argo CD
   │
   │ Sync
   ▼
Amazon EKS
   │
   ▼
Kubernetes Application
```

---

#  Architecture

The project follows a separation between **CI** and **CD**.

### Continuous Integration

Jenkins is responsible for:

```text
Source Code
    ↓
Build
    ↓
Docker Image
    ↓
Amazon ECR
    ↓
Update Kubernetes Manifest
    ↓
Git Commit & Push
```

### Continuous Deployment

Argo CD is responsible for:

```text
GitHub
   ↓
Detect Repository Changes
   ↓
GitOps Synchronization
   ↓
Amazon EKS
   ↓
Application Deployment
```

This approach ensures that the desired Kubernetes state is stored in Git and that Argo CD continuously reconciles the cluster with the repository.

---

# 🔄 CI/CD Workflow

When a new change is pushed to the repository, the following process takes place:

### 1. Source Code

The application source code is maintained in GitHub.

```text
GitHub Repository
       ↓
       Jenkins
```

### 2. Jenkins Checkout

Jenkins checks out the latest source code from the repository.

### 3. Docker Build

Jenkins builds a Docker image from the application:

```text
app/
   ↓
Dockerfile
   ↓
Docker Image
```

### 4. Amazon ECR

The generated image is tagged using the Jenkins build number and pushed to Amazon ECR.

Example:

```text
036253061913.dkr.ecr.eu-west-1.amazonaws.com/devops:15
```

### 5. Kubernetes Manifest Update

Jenkins updates the image tag inside:

```text
k8s/kustomization.yaml
```

Example:

```yaml
images:
  - name: 036253061913.dkr.ecr.eu-west-1.amazonaws.com/devops
    newTag: 15
```

### 6. Git Commit & Push

Jenkins commits the updated Kubernetes configuration and pushes it back to GitHub.

Example:

```text
Update image tag to 15
```

### 7. Argo CD Synchronization

Argo CD detects the change in Git and synchronizes the desired state with the Kubernetes cluster.

### 8. Amazon EKS Deployment

The updated application is deployed to the Amazon EKS cluster using the new Docker image.

---

# ☁️ Infrastructure

The infrastructure is provisioned using **Terraform**.

The AWS environment includes:

* Amazon VPC
* Public and private subnets
* Availability Zones
* Amazon EKS cluster
* EKS managed node group
* Networking components required by the cluster

### EKS Cluster

```text
Cluster Name: devsecops-eks
Region:       eu-west-1
```

Terraform is organized into reusable configuration files and an EKS module.

---

# 🐳 Containerization

The application is containerized using Docker.

The Docker image is built by Jenkins and stored in Amazon ECR.

### Image Tagging Strategy

The Jenkins build number is used as the Docker image tag.

For example:

```text
Jenkins Build #1   → devops:1
Jenkins Build #2   → devops:2
Jenkins Build #10  → devops:10
Jenkins Build #15  → devops:15
```

This provides a simple versioning mechanism and allows each CI build to be uniquely identified.

---

#  GitOps with Argo CD

This project follows the GitOps methodology.

Instead of Jenkins directly deploying resources to Kubernetes using:

```bash
kubectl apply
```

Jenkins updates the Kubernetes configuration stored in Git.

Argo CD then uses Git as the **source of truth**.

```text
Jenkins
   │
   │ Update Manifest
   ▼
GitHub
   │
   │ Desired State
   ▼
Argo CD
   │
   │ Reconcile
   ▼
Amazon EKS
```

This separation provides a cleaner architecture:

```text
Jenkins → CI
Argo CD → CD
```

---

# ☸️ Kubernetes

Kubernetes manifests are maintained under:

```text
k8s/
```

Kustomize is used to manage Kubernetes image configuration.

Example:

```yaml
images:
  - name: ****061913.dkr.ecr.eu-west-1.amazonaws.com/devops
    newTag: 15
```

Jenkins automatically updates `newTag` whenever a new image is built.

---

# 📂 Project Structure

```text
Devops-project/
│
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── application source code
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── output.tf
│   │
│   └── eks/
│       ├── main.tf
│       ├── variables.tf
│       └── output.tf
│
├── Jenkinsfile
│
└── README.md
```

---

# 🛠️ Technology Stack

| Technology     | Role                                |
| -------------- | ----------------------------------- |
| **GitHub**     | Source Code & GitOps Repository     |
| **Jenkins**    | Continuous Integration              |
| **Docker**     | Application Containerization        |
| **Amazon ECR** | Container Image Registry            |
| **Kubernetes** | Container Orchestration             |
| **Amazon EKS** | Managed Kubernetes Platform         |
| **Argo CD**    | GitOps Continuous Deployment        |
| **Terraform**  | Infrastructure as Code              |
| **Kustomize**  | Kubernetes Configuration Management |

---

# 🔐 Security & Credentials

Sensitive credentials are not stored directly in the Git repository.

Jenkins manages authentication through Jenkins Credentials.

### AWS

AWS credentials are stored securely in Jenkins and are used for:

```text
AWS Authentication
       ↓
Amazon ECR Login
       ↓
Docker Image Push
```

### GitHub

An SSH credential is configured in Jenkins for pushing the updated Kubernetes manifests back to GitHub.

Private keys and credentials must never be committed to the repository.

### Files That Should Not Be Committed

```text
.env
*.pem
*.key
AWS credentials
SSH private keys
terraform.tfstate
terraform.tfstate.*
```

A proper `.gitignore` should be maintained to prevent accidental exposure of sensitive information.

---

# 📊 Project Status

## Completed

* [x] AWS infrastructure provisioned with Terraform
* [x] VPC and networking configured
* [x] Amazon EKS cluster created
* [x] EKS managed node group configured
* [x] Application containerized with Docker
* [x] Amazon ECR repository configured
* [x] Jenkins CI pipeline configured
* [x] AWS authentication configured in Jenkins
* [x] Docker image build automated
* [x] Docker image pushed to Amazon ECR
* [x] Kubernetes image tag updated automatically
* [x] Git commit and push automated
* [x] Argo CD GitOps workflow configured
* [x] Application deployment workflow prepared for Amazon EKS

---

# 🔜 Future Improvements

The following components are planned for future iterations:

* [ ] Trivy container vulnerability scanning
* [ ] SonarQube code quality analysis
* [ ] Additional security gates
* [ ] Monitoring and observability
* [ ] Centralized logging
* [ ] Improved deployment strategies
* [ ] Automated rollback mechanisms

---

# 🎯 Project Objectives

This project demonstrates practical implementation of modern DevOps principles:

### Infrastructure as Code

Terraform is used to provision and manage AWS infrastructure.

### Continuous Integration

Jenkins automates the application build and container image delivery process.

### Containerization

Docker provides a consistent and portable application runtime.

### Container Registry

Amazon ECR securely stores versioned Docker images.

### GitOps

GitHub acts as the source of truth for the Kubernetes desired state.

### Continuous Deployment

Argo CD automatically synchronizes Kubernetes resources with the Git repository.

### Container Orchestration

Amazon EKS provides the managed Kubernetes environment where the application runs.

---

# 🚀 Final Architecture

```text
                         ┌─────────────────┐
                         │     Developer   │
                         └────────┬────────┘
                                  │
                                  │ git push
                                  ▼
                         ┌─────────────────┐
                         │     GitHub      │
                         └────────┬────────┘
                                  │
                                  │ Checkout
                                  ▼
                         ┌─────────────────┐
                         │     Jenkins     │
                         │       CI        │
                         └────────┬────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
             Docker Build                 Update K8s
                    │                      Manifest
                    ▼                           │
             Amazon ECR                         │
                    │                           │
                    └─────────────┬─────────────┘
                                  │
                                  │ git push
                                  ▼
                         ┌─────────────────┐
                         │     GitHub      │
                         │  Source of Truth│
                         └────────┬────────┘
                                  │
                                  │ GitOps
                                  ▼
                         ┌─────────────────┐
                         │     Argo CD     │
                         │       CD        │
                         └────────┬────────┘
                                  │
                                  │ Sync
                                  ▼
                         ┌─────────────────┐
                         │   Amazon EKS    │
                         │   Kubernetes    │
                         └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │   Application   │
                         └─────────────────┘
```

---

# 👨‍💻 Project Summary

This project demonstrates an end-to-end **CI/CD and GitOps workflow** using AWS and open-source DevOps technologies.

The final delivery flow is:

```text
GitHub
   ↓
Jenkins
   ↓
Docker
   ↓
Amazon ECR
   ↓
GitHub
   ↓
Argo CD
   ↓
Amazon EKS
   ↓
Application
```

The architecture separates **Continuous Integration** from **Continuous Deployment**, while using Git as the central source of truth for application deployment configuration.
