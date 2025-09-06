pipeline {
    agent any

    tools {
        maven 'maven-3'
    }

    environment {
        // Cache Maven dependencies
        MAVEN_OPTS = "-Dmaven.repo.local=/var/lib/jenkins/.m2/repository"
        AWS_ACCOUNT_ID = "927788617166"
        AWS_REGION     = "eu-north-1"
        ECR_REPO       = "simple-java-app"
        IMAGE_TAG      = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean install -DskipTests'
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
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                docker tag ${ECR_REPO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
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

