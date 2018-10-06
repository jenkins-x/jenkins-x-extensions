pipeline {
    agent {
        label "jenkins-go"
    }
    environment {
      ORG               = 'jenkins-x'
      APP_NAME          = 'jenkins-x-extensions'
      GIT_PROVIDER      = 'github.com'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
            checkout scm
            container('go') {
              sh "make build"
            }
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          container('go') {
            dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
              checkout scm
            }
            dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
              // so we can retrieve the version in later steps
              sh "echo \$(jx-release-version) > VERSION"
            }
            dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
              container('go') {
                sh "make build"
                sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'

              }
            }
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
