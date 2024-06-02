pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "reg.kipya.com/kipya/jenkins:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']], 
                          doGenerateSubmoduleConfigurations: false, 
                          extensions: [], 
                          userRemoteConfigs: [[url: 'https://github.com/your-username/your-repo.git']]])
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
                withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD')]) {
                    script {
                        docker.withRegistry('https://reg.kipya.com', 'harbor-credentials') {
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
