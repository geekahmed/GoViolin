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
        stage('Configuring AWS EKS InfraStructure'){
            steps{
                withAWS(region:'us-west-2', credentials:'geekahmed-aws'){
                sh 'aws eks --region us-west-2 update-kubeconfig --name goviolin'
                }
            }
        }        
        stage('Apply Deployment of GoViolin'){
            steps{
                dir('kubernetes'){
                    withAWS(region:'us-west-2', credentials:'geekahmed-aws'){
                        sh '$(which kubectl) apply -f app.yml'
                }
            }
            }

        }
        stage('Update deployment') {
            steps {
                dir('kubernetes') {
                    withAWS(region:'us-west-2', credentials:'geekahmed-aws') {
                            sh "$(which kubectl) set image deployments/goviolin goviolin=geekahmed/goviolin:${BUILD_NUMBER}"
                        }
                    }
            }
        }
        stage('Wait for pods') {
            steps {
                withAWS(region:'us-west-2', credentials:'geekahmed-aws') {
                    sh '''
                        ATTEMPTS=0
                        ROLLOUT_STATUS_CMD="kubectl rollout status deployment/goviolin"
                        until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
                            $ROLLOUT_STATUS_CMD
                            ATTEMPTS=$((attempts + 1))
                            sleep 10
                        done
                    '''
                }
            }
        }

        stage('Post deployment test') {
            steps {
                withAWS(region:'us-west-2', credentials:'geekahmed-aws') {
                    sh '''
                        HOST=$($(which kubectl) get service service-goviolin | grep 'amazonaws.com' | awk '{print $4}')
                        curl $HOST -f
                    '''
                }
            }
        }   
        stage("Prune docker") {
            steps {
                sh "docker system prune -f"
            }
        }     
    }
}