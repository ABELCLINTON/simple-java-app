pipeline {
    agent any

    tools {
        maven 'maven-3' // Or whatever name you've configured for Maven in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/ABELCLINTON/simple-java-app']])
                sh 'mvn clean install'
            }
        }
        stage('docker build') {
            steps {
                sh 'docker build -t simple-java-app .'


                
            }
        }
        stage('dockerimage push to ecr') {
            steps {
                script {
                    sh '''
                    (Get-ECRLoginCommand).Password | docker login --username AWS --password-stdin 927788617166.dkr.ecr.eu-north-1.amazonaws.com
                    docker build -t jenkins-docker-push .
                    docker tag jenkins-docker-push:latest 927788617166.dkr.ecr.eu-north-1.amazonaws.com/jenkins-docker-push:latest
                    docker push 927788617166.dkr.ecr.eu-north-1.amazonaws.com/jenkins-docker-push:latest
                    '''
                }
            }
        }
    }  

    post {
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed.'
        }
    }
}    
