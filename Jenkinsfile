pipeline {
  agent any
  stages {
    stage('Compile') {
      steps {
        echo "Compile stage"
      }
    }
    stage('Build') {
      steps {
        echo "Build stage"
      }
    }
    stage ('Test') {
      steps {
        echo "Test stage"
      }
    }
    stage('Deploy') {
      steps {
        echo "Deploy stage"
      }
    }
  }
  post {
    always {
      echo "This will always run"
    }
    success {
      echo "This will run only on SUCCESS"
    }
    failure {
      echo "This will run only on FAILURE"
    }
    unstable {
      echo "This will run only on UNSTABLE BUILD"
    }
    changed {
      echo "This will run only if state of the pipeline has changed"
    }
  }
}
