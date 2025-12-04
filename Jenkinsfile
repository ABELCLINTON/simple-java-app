pipeline {
    agent any

    tools {
        maven 'maven-3'
        
    }

    environment {
        // Cache Maven dependencies
        MAVEN_OPTS = "-Dmaven.repo.local=/var/lib/jenkins/.m2/repository"
        AWS_ACCOUNT_ID = "971431175998"
        AWS_ACCESS_KEY_ID = "AKIA6ELOPM47CZNQ5RQN"
        AWS_SECRET_ACCESS_KEY = "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"
        AWS_REGION     = "eu-north-1"
        ECR_REPO       = "terra-ecr"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        TF_DIR = '.'
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
                aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 898203562748.dkr.ecr.us-east-1.amazonaws.com
                docker tag $ECR_REPO:$IMAGE_TAG 898203562748.dkr.ecr.us-east-1.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                docker push 898203562748.dkr.ecr.us-east-1.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                '''
            }
        }
        stage('Terraform Init') {
            steps {
                dir("${env.TF_DIR}") {
                    sh '''
                        terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${env.TF_DIR}") {
                    sh '''
                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${env.TF_DIR}") {
                    sh '''
                        terraform plan \
                        -var 'aws_account_id=898203562748' \
                        -var 'aws_region=us-east-1' \
                        -var 'ecr_repo=terra-ecr' \
                        -var 'image_tag=${BUILD_NUMBER}' \
                        -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply (Deploy ECS)') {
            steps {
                dir("${env.TF_DIR}") {
                    sh '''
                        terraform apply -auto-approve -var "image_tag=${BUILD_NUMBER}"
                    '''
                }
            }
        }

        stage('Post-Deploy Info') {
            steps {
                dir("${env.TF_DIR}") {
                    sh '''
                        terraform output
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
