pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "reg.kipya.com/kipya/jenkins"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def scmVars = checkout([$class: 'GitSCM', 
                        branches: [[name: '*/main']], 
                        doGenerateSubmoduleConfigurations: false, 
                        extensions: [], 
                        userRemoteConfigs: [[url: 'https://github.com/bit2big/bit2big-jenkins.git']]
                    ])
                    GIT_COMMIT_HASH = scmVars.GIT_COMMIT[0..6]
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${DOCKER_IMAGE}:${GIT_COMMIT_HASH}"
                    def latestTag = "${DOCKER_IMAGE}:latest"

                    // Build the Docker image with the commit hash tag
                    dockerImage = docker.build(imageTag)

                    // Tag the image with the 'latest' tag
                    dockerImage.tag('latest')
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD')]) {
                    script {
                        docker.withRegistry('https://reg.kipya.com', 'harbor-credentials') {
                            // Push the image with the commit hash tag
                            dockerImage.push("${GIT_COMMIT_HASH}")

                            // Push the image with the 'latest' tag
                            dockerImage.push('latest')
                        }
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    sh 'docker system prune -f'
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