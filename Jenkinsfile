pipeline {
    agent any
    tools {
        go 'go-1.16'
    }
    environment {
        GO111MODULE = 'on'
        CGO_ENABLED = '0'
        GOOS = 'linux'
        GOARCH = 'amd64'
        imagename = "geekahmed/goviolin"
        registryCredential = 'geekahmed-dockerhub'
        dockerImage = ''
    }
stages {
        stage('Installing Dependencies'){
            steps {
                sh 'go mod download'
                sh 'go mod verify'
            }
        }
        stage('Compile') {
            steps {
                sh 'go build'
            }
        }
        stage('Test') {
            steps {
                sh 'go test ./... -coverprofile=coverage.txt'
            }
        }
        stage('Building Docker Image'){
            steps{
                script {
                    dockerImage = docker.build imagename
             }
        }
        }
        stage('Deploy Docker Image'){
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                    dockerImage.push("$BUILD_NUMBER")
                    dockerImage.push('latest')
                }                
            }
        }
        }
        stage('Clean Docker Image'){
            steps{
                sh "docker rmi $imagename:$BUILD_NUMBER"
                sh "docker rmi $imagename:latest"
            }
        }

    }
}