pipeline {
    agent any

    environment {
        REGISTRY = "reg.kipya.com"
        REPOSITORY = "kipya/jenkins"
        LATEST_TAG = "latest"
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
                    // Get the short commit hash
                    GIT_COMMIT_HASH = scmVars.GIT_COMMIT[0..6]
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${REGISTRY}/${REPOSITORY}:${GIT_COMMIT_HASH}"
                    def latestTag = "${REGISTRY}/${REPOSITORY}:${LATEST_TAG}"

                    // Build the Docker image with the commit hash tag
                    dockerImage = docker.build(imageTag)

                    // Tag the image with the 'latest' tag
                    dockerImage.tag(latestTag)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD')]) {
                    script {
                        docker.withRegistry("https://${REGISTRY}", 'harbor-credentials') {
                            // Push the image with the commit hash tag
                            dockerImage.push("${GIT_COMMIT_HASH}")

                            // Push the image with the 'latest' tag
                            dockerImage.push("${LATEST_TAG}")
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