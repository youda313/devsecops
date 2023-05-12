//Take this file and replace the Jenkinsfile in the root directory
//make sure to select 'pipeline script from SCM' then Gitand set the repo URL
//make sure to tick the GitHub hook trigger for GITScm polling
// Running Jacoco for test code coverage

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
            post { 
                always { 
                    junit 'target/surefire-reports/*.xml'
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }   
    }
}
