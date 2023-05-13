//Take this file and replace the Jenkinsfile in the root directory
//make sure to select 'pipeline script from SCM' then Gitand set the repo URL
//make sure to tick the GitHub hook trigger for GITScm polling
// build and push docker container to dockerhub

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

        stage('Docker Build and Push') {
            steps {
                withDockerRegistry([credentialsId: "docker-hub-token", url: "") {
                sh 'printenv'
                sh 'sudo docker build -t youda313/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push youda313/numeric-app:""$GIT_COMMIT""'
                }
            }
        }


    }
}
