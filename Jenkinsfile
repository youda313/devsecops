//make sure to select 'pipeline script from SCM' then Gitand set the repo URL
//make sure to tick the GitHub hook trigger for GITScm polling

pipeline {
    agent any

    stages {
        stage('build artifact') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archive 'target/*.jar'
            }
        }

        stage('Unit Tests') {
            steps {
                sh "mvn test"
            }
        }
    }
}
