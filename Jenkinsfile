
pipeline {
    agent any
    environment {
      ORG               = 'jenkinsxio'
      APP_NAME          = 'jenkins-x-extensions'
      GIT_PROVIDER      = 'github.com'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
            checkout scm
            sh "make build"
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
            git 'https://github.com/jenkins-x/jenkins-x-extensions'
          }
          dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
            // ensure we're not on a detached head
            sh "git checkout master"
            // until we switch to the new kubernetes / jenkins credential implementation use git credentials store
            sh "git config --global credential.helper store"

            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }
          dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
            sh "VERSION=\$(cat VERSION) make build"
          }
        }
      }
      stage('Promote') {
        when {
          branch 'master'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/jenkins-x/jenkins-x-extensions') {
            sh "VERSION=\$(cat VERSION) make tag"
            sh 'jx step changelog --version v\$(cat VERSION)'
            // Run updatebot to update other repos
            sh './updatebot.sh'
          }
        }
      }
    }
  }
