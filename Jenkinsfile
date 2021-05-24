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
    }
stages {
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
        stage('Code Analysis') {
            steps {
                sh 'curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v1.12.5'
                sh 'golangci-lint run'
            }
        }
    }
}