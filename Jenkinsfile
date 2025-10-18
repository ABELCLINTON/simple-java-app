pipeline {
    agent any

    tools {
        maven 'maven-3'
    }

    environment {
        MAVEN_OPTS     = "-Dmaven.repo.local=/var/lib/jenkins/.m2/repository"
        AWS_ACCOUNT_ID = "927788617166"
        AWS_REGION     = "us-east-1"        // must match Terraform provider
        ECR_REPO       = "terra-ecr"
        IMAGE_TAG      = "${BUILD_NUMBER}"  // auto-increment tag
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/ABELCLINTON/simple-java-app.git']])
                
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn install -DskipTests'
            }
        }

        stage('Docker Build & Push to ECR') {
            steps {
                echo 'Starting Docker build and push stage...'
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''#!/bin/bash
                        set -xe
                        echo "Docker path: $(which docker)"
                        echo "AWS path: $(which aws)"

                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 927788617166.dkr.ecr.us-east-1.amazonaws.com

                        docker build -t terra-ecr .
                        docker tag terra-ecr:latest 927788617166.dkr.ecr.us-east-1.amazonaws.com/terra-ecr:latest
                        docker push 927788617166.dkr.ecr.us-east-1.amazonaws.com/terra-ecr:latest
                    '''
                }
            }
        }

        stage('Terraform Init/Plan/Apply') {
            steps {
                dir('ecsfargate.tf') {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                        ]) {
                        sh '''#!/bin/bash
                            set -xe
                            terraform init -input=false
                            terraform plan -out=tfplan -input=false \
                            -var="aws_account_id=${AWS_ACCOUNT_ID}" \
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
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                    sh '''#!/bin/bash
                        set -xe
                        aws ecs update-service \
                        --cluster fargate-cluster \
                        --service fargate-service \
                        --force-new-deployment \
                        --region ${AWS_REGION}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build, Push, Terraform Apply & ECS Deploy completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed.'
        }
    }
}

