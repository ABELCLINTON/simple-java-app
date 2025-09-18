pipeline {
    agent any

    tools {
        maven 'maven-3'
    }

    environment {
        // Cache Maven dependencies
        MAVEN_OPTS = "-Dmaven.repo.local=/var/lib/jenkins/.m2/repository"
        AWS_ACCOUNT_ID = "927788617166"
        AWS_ACCESS_KEY_ID = "AKIA5QBECZXHEO7AHIQQ"
        AWS_SECRET_ACCESS_KEY = "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"
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
                docker tag new-ecr:latest 927788617166.dkr.ecr.us-east-1.amazonaws.com/new-ecr:latest
                docker push 927788617166.dkr.ecr.us-east-1.amazonaws.com/new-ecr:latest
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

