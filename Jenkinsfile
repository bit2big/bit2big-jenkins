pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "bit2big/jenkins:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']], 
                          doGenerateSubmoduleConfigurations: false, 
                          extensions: [], 
                          userRemoteConfigs: [[url: 'https://github.com/bit2big/bit2big-jenkins.git']]])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build(env.DOCKER_IMAGE)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                            dockerImage.push()
                        }
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    docker.imagePrune()
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}