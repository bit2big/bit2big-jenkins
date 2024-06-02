pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_REGISTRY', defaultValue: 'reg.kipya.com', description: 'Docker Registry URL')
        string(name: 'DOCKER_REPOSITORY', defaultValue: 'kipya/jenkins', description: 'Docker Repository')
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Git Branch to Build')
    }

    environment {
        DOCKER_IMAGE = "${params.DOCKER_REGISTRY}/${params.DOCKER_REPOSITORY}:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def scmVars = checkout([$class: 'GitSCM', 
                        branches: [[name: "*/${params.BRANCH_NAME}"]], 
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
                    def imageTag = "${params.DOCKER_REGISTRY}/${params.DOCKER_REPOSITORY}:${GIT_COMMIT_HASH}"
                    def latestTag = "${params.DOCKER_REGISTRY}/${params.DOCKER_REPOSITORY}:${LATEST_TAG}"

                    dockerImage = docker.build(imageTag)
                    dockerImage.tag(latestTag)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD')]) {
                    script {
                        docker.withRegistry("https://${params.DOCKER_REGISTRY}", 'harbor-credentials') {
                            dockerImage.push("${GIT_COMMIT_HASH}")
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
