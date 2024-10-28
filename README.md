# COSC2759 Assignment 2, 2023

## Student Details

- Full Name: Carlson Mun
- Student ID: s4005369

## Overview of My Solution

This project aims to deploy a resilient, secure environment for a Node.js application backed by a PostgreSQL database, all hosted on AWS. The deployment uses Terraform for infrastructure provisioning, Ansible for configuration management, and Docker for containerization, ensuring a smooth and efficient process from infrastructure setup to application deployment.

### Infrastructure Setup

The architecture was designed with high availability, scalability, and security in mind, focusing on ensuring the application is always available to users while keeping the environment secure. Below is a detailed breakdown of the infrastructure:

- **EC2 Instances**:
  - **App Instances**: Two EC2 instances host the Node.js application. These instances are behind an AWS Elastic Load Balancer (ELB) to ensure high availability and traffic distribution, making the application robust against failures.
  - **Database Instance**: A separate EC2 instance is used to host the PostgreSQL database, which ensures the database is isolated for added security.

- **Load Balancer**: An AWS Elastic Load Balancer (ELB) is used to distribute incoming HTTP requests evenly across the two application instances. The ELB provides fault tolerance so that if one instance becomes unavailable, traffic is redirected to the other instance, ensuring the application remains accessible.

- **Security Groups**:
  - **App Security Group**: Configured to allow HTTP traffic on port 80 from anywhere, which ensures that the web application is accessible to users. SSH access on port 22 is restricted to trusted IP addresses for management.
  - **Database Security Group**: This group allows inbound traffic only on port 5432, restricted to the app instances' IP addresses, ensuring secure communication between the application and the database. SSH access is also allowed for administrative purposes.

- **AWS S3 and Terraform State**: An S3 bucket is used for storing Terraform state files. This helps maintain a centralized and consistent state, enabling collaboration, tracking of changes, and disaster recovery.

- **Private Networking**: The app instances communicate with the PostgreSQL database instance over a private subnet, ensuring secure communication while preventing direct public access to the database.

### Data Flow Overview

1. **Client Requests**:
   - Users interact with the system through a browser, sending HTTP requests to the load balancer.
   - The ELB is responsible for distributing requests to the app instances.

2. **Load Balancer**:
   - The load balancer acts as the entry point, passing incoming requests to one of the available app instances to ensure even load distribution.

3. **App Server Processing**:
   - The Node.js application processes user requests. For static content, the server directly responds to the user. For database-related requests, it sends queries to the PostgreSQL instance.

4. **Database Communication**:
   - The PostgreSQL instance processes requests from the app servers and sends back the results. Since the database is in a private subnet, it is protected from public internet access, which enhances security.

5. **Response to Client**:
   - After processing data, the app server sends a response back to the client through the load balancer, providing a seamless user experience.

### Deployment Steps

The deployment of the infrastructure and application was automated using **Terraform**, **Ansible**, and **GitHub Actions**. Here is the detailed breakdown:

#### Prerequisites

- **Terraform** must be installed to provision infrastructure.
- **Ansible** is required for configuring EC2 instances.
- **AWS credentials** are configured via GitHub Secrets for deployment automation.
- **SSH private key** stored in GitHub Secrets for secure SSH access to instances.

#### Deployment Workflow

The deployment is managed through **GitHub Actions**, which automates the entire process from infrastructure setup to application deployment.

- **GitHub Actions Workflow**:
  - When code is pushed to the `main` branch, the workflow automatically begins.
  - It starts by installing necessary tools like Terraform, Ansible, Docker, and AWS CLI.
  - **AWS credentials** are set up using GitHub Secrets to ensure secure access to AWS services.
  - **Terraform** is used to provision EC2 instances, security groups, load balancer, and other resources.
  - **Ansible** playbooks are run to configure the EC2 instances with Docker, set up the necessary software, and launch the Node.js app container.

#### Manual Backup Deployment with Shell Script

A `deploy.sh` script is provided as a backup in case the GitHub Actions workflow is unavailable or fails.
- The script first runs `terraform init` and `terraform apply` to provision the infrastructure.
- The script then configures the servers using an Ansible playbook, which is helpful for cases where automated CI/CD is not feasible.

#### Testing the Application

After deploying, it is crucial to ensure the application is running properly:

1. **Access the Application**:
   - Use the load balancer's public DNS to check if the app is accessible in the browser.
   - The app should show a "Hello World :-)" message and have a link to view the list of foos.

2. **Database Connection**:
   - The `/foos` endpoint verifies the app can connect to the PostgreSQL database.
   - If there are issues, SSH into the app server and inspect Docker container logs to troubleshoot.

3. **Check Logs**:
   - Docker logs can be used to check both the application and database for any runtime errors.
   - Use the following command to view logs:
     ```sh
     sudo docker logs <container_name>
     ```

### Directory Structure

- **terraform/**: Contains Terraform configurations used to provision all AWS resources.
- **ansible/**: Holds playbooks to automate configuration on the app and database servers.
- **app/**: Contains the Node.js application code and configuration.
  - **views/**: Contains EJS templates (`index.ejs`, `foos.ejs`) for rendering app pages.
  - **Dockerfile**: Used for building the Docker image for the Node.js app.
  - **.env**: Environment variables for database credentials and other configurations.
  - **index.js**: The main server-side code for running the Node.js app.
- **.github/workflows/**: Contains the GitHub Actions workflows for deployment.
  - **deploy.yml**: Defines the CI/CD pipeline for building and deploying the infrastructure and app.
- **deploy.sh**: Backup shell script for deploying without CI/CD.
- **README.md**: This document, which explains the project.

### Technologies Used

- **AWS**: For hosting the application and database.
- **Docker**: Containerizes the application to provide a consistent environment.
- **Terraform**: Automates the creation of infrastructure.
- **Ansible**: Used to configure the instances after they're created.
- **GitHub Actions**: Automates the deployment process.

### Conclusion

This project showcases how to create a scalable, secure, and resilient infrastructure for a Node.js app using modern DevOps tools. By utilizing AWS for cloud infrastructure, Docker for containerization, and automating deployment with Terraform, Ansible, and GitHub Actions, the goal was to ensure that the app is always available, secure, and easy to maintain. This setup provides the flexibility needed to adapt to real-world production traffic while keeping everything manageable and reproducible.

If you need to deploy or update this project, follow the instructions provided in the respective sections, and feel free to use the `deploy.sh` script as a backup if the GitHub Actions workflow is unavailable.

