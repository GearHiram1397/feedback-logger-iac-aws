# Feedback Logger IaC AWS

A complete example project for deploying a microservice to AWS using Docker, Terraform, and GitHub Actions.

## Project Purpose
This project demonstrates best practices for deploying a simple Node.js + Express feedback API as a containerized microservice on AWS ECS Fargate, using Infrastructure as Code (IaC) with Terraform and automated CI/CD with GitHub Actions.

## Tech Stack
- Node.js + Express backend
- React + Vite + Tailwind frontend
- Docker
- AWS ECS (Fargate), ECR, IAM, VPC
- Terraform
- GitHub Actions

## Features
- `/submit-feedback` POST endpoint to receive JSON feedback
- Production-ready Docker container
- Infrastructure managed via Terraform
- Automated build, push, and deploy via GitHub Actions
- Uses environment variables for secrets

## Prerequisites
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured (`aws configure`)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Docker](https://docs.docker.com/get-docker/)
- AWS account with permissions for ECS, ECR, IAM, and VPC

## Setup & Deployment

### 1. Clone the repository
```sh
git clone https://github.com/your-username/feedback-logger-iac-aws.git
cd feedback-logger-iac-aws
```

### 2. Set up environment variables
Copy `.env.example` to `.env` and fill in your secrets:
```sh
cp .env.example .env
```

### 3. Build and run locally (optional)
Build the React app and start the API server using Docker:
```sh
docker build -t feedback-logger .
docker run --env-file .env -p 3000:3000 feedback-logger
```

### 4. Deploy to AWS
#### a. Initialize and apply Terraform
```sh
cd terraform
terraform init
terraform apply -auto-approve \
  -var="ecr_image_url=<your_ecr_image_url>" \
  -var="api_secret=<your_api_secret>"
```
#### b. Push Docker image to ECR
- Authenticate Docker to ECR:
  ```sh
  aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
  ```
- Build, tag, and push:
  ```sh
  docker build -t feedback-logger .
  docker tag feedback-logger:latest <your_ecr_image_url>
  docker push <your_ecr_image_url>
  ```

#### c. Update ECS service (if needed)
- Re-run `terraform apply` with the new image URL.

### 5. CI/CD with GitHub Actions
- On every push to `main`, the workflow in `.github/workflows/deploy.yml` will:
  - Build and push the Docker image to ECR
  - Deploy infrastructure and update the ECS service using Terraform
- Store your AWS credentials and API secret in GitHub repository secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `API_SECRET`

## Testing the API
Once deployed, find the public endpoint (ECS service public IP or load balancer DNS). Test with:

### Using curl
```sh
curl -X POST http://<service-endpoint>:3000/submit-feedback \
  -H "Content-Type: application/json" \
  -H "x-api-key: <your_api_secret>" \
  -d '{ "message": "Loved the experience!" }'
```

### Using Postman
- Set method to POST
- URL: `http://<service-endpoint>:3000/submit-feedback`
- Body: raw JSON `{ "message": "Loved the experience!" }`
- Header `x-api-key: <your_api_secret>`

## Project Structure
```
feedback-logger-iac-aws/
├── app.js
├── package.json
├── frontend/
│   ├── src/
│   └── dist/
├── Dockerfile
├── .env.example
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── .github/
    └── workflows/
        └── deploy.yml
```

## Notes
- All secrets are managed via environment variables and GitHub secrets.
- Terraform code is modular and commented for clarity.
- The API is stateless and ready for extension (e.g., add DB integration).

---

**Impress recruiters:** This project demonstrates clean code, modular infrastructure, and a professional CI/CD pipeline for real-world cloud deployments. 
