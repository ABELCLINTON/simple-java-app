pipeline {
    agent any

    tools {
        maven 'maven-3'
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
                docker tag terra-ecr:latest 927788617166.dkr.ecr.us-east-1.amazonaws.com/terra-ecr:${BUILD_NUMBER}
                docker push 927788617166.dkr.ecr.us-east-1.amazonaws.com/terra-ecr:${BUILD_NUMBER}
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
