//Take this file and replace the Jenkinsfile in the root directory
//make sure to select 'pipeline script from SCM' then Gitand set the repo URL
//make sure to tick the GitHub hook trigger for GITScm polling
// SONARQUBE quality gates

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

        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post{
                always{
                    pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }


        stage('SonarQube - SAST') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "mvn clean verify sonar:sonar \
                                -Dsonar.projectKey=numeric-application \
                                -Dsonar.projectName='numeric-application' \
                                -Dsonar.host.url=http://192.168.1.201:9000 \
                                -Dsonar.token=sqp_dfb97ec3c4ef6ac8c009c58190ded8e1afe2425f"
                }
                // timeout(time: 2, unit: 'MINUTES') {
                //     script {
                //         waitForQualityGate abortPipeline: true
                //     }
                // }
            }
        }


        stage('Docker Build and Push') {
            

            steps {
                withDockerRegistry([credentialsId: "docker-hub-token", url: ""]) {
                    sh 'printenv'
                    sh 'docker build -t youda313/numeric-app:""$GIT_COMMIT"" .'
                    sh 'docker push youda313/numeric-app:""$GIT_COMMIT""'
                }

            }
        }

        stage('K8S Deployment - DEV') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh 'printenv'
                    sh "sed -i 's#replace#youda313/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                    sh "kubectl apply -f k8s_deployment_service.yaml"
                }
            }
          
        }


    


    }
}
