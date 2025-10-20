pipeline {
    agent any

    tools {
        maven 'maven-3'
        terraform 'terraform-latest'
    }

    environment {
        // Cache Maven dependencies
        MAVEN_OPTS = "-Dmaven.repo.local=/var/lib/jenkins/.m2/repository"
        AWS_ACCOUNT_ID = "927788617166"
        AWS_ACCESS_KEY_ID = "AKIA5QBECZXHJGWC4Q4N"
        AWS_SECRET_ACCESS_KEY = "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"
        AWS_REGION     = "eu-north-1"
        ECR_REPO       = "terra-ecr"
        IMAGE_TAG      = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn install -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 927788617166.dkr.ecr.us-east-1.amazonaws.com
                docker tag $ECR_REPO:$IMAGE_TAG 927788617166.dkr.ecr.us-east-1.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                docker push 927788617166.dkr.ecr.us-east-1.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                '''
            }
        }
        stage('Terraform Init/Plan/Apply') {
            steps {
                dir("${TF_DIR}") {
                    withCredentials([
                        string(credentialsId: 'AKIA5QBECZXHJGWC4Q4N', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'VkJVVB9Ebw3Wyz9lHQwKF5rM/Kfh1mcvh5zhNIih', variable: 'AWS_SECRET_ACCESS_KEY')
                        ]) {
                        sh '''#!/bin/bash
                        set -xe
                        terraform init -input=false
                        terraform plan -out=tfplan -input=false \
                        -var="aws_account_id=${927788617166}" \
                        -var="aws_region=${AWS_REGION}" \
                        -var="ecr_repo=${ECR_REPO}" \
                        -var="image_tag=${IMAGE_TAG}"
                        terraform apply -input=false -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withCredentials([
                    string(credentialsId: 'AKIA5QBECZXHJGWC4Q4N', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'VkJVVB9Ebw3Wyz9lHQwKF5rM/Kfh1mcvh5zhNIih', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                    aws ecs update-service \
                    --cluster fargate-cluster \
                    --service fargate-service \
                    --force-new-deployment \
                    --region ${AWS_REGION}
                    '''
                }
            }
        }
         stage('Terraform Destroy (Cleanup)') {
            steps {
                input message: 'Proceed to destroy the infrastructure?', ok: 'Yes, destroy'
                sh '''
                terraform destroy -auto-approve
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Build & Push completed successfully!'
        }
        failure {
            echo '❌ Build failed.'
        }
    }
}
