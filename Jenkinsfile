//Take this file and replace the Jenkinsfile in the root directory
//make sure to select 'pipeline script from SCM' then Gitand set the repo URL
//make sure to tick the GitHub hook trigger for GITScm polling
// Integration to Slack
@Library('slack') _

pipeline {
    agent any

    environment {
        deploymentName = "devsecops"
        containerName = "devsecops-container"
        serviceName = "devsecops-svc"
        imageName = "youda313/numeric-app:${GIT_COMMIT}"
        applicationURL="http://mattlab.ddns.net"
        applicationURI="/increment/99"
    }

    stages {
//         stage('build artifact') {
//             steps {
//                 sh "mvn clean package -DskipTests=true"
//                 archive 'target/*.jar'
//             }
//         }

//         stage('Unit Tests') {
//             steps {
//                 sh "mvn test"
//             }
//         }

//         stage('Mutation Tests - PIT') {
//             steps {
//                 sh "mvn org.pitest:pitest-maven:mutationCoverage"
//             }
//             post{
//                 always{
//                     pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
//                 }
//             }
//         }


//         stage('SonarQube - SAST') {
//             steps {
//                 withSonarQubeEnv('My SonarQube Server'){

//                         sh "mvn clean verify sonar:sonar \
//                                     -Dsonar.projectKey=numeric-application \
//                                     -Dsonar.projectName='numeric-application' \
//                                     -Dsonar.host.url=http://192.168.1.201:9000 \
//                                     -Dsonar.token=sqp_e9343ff021ddb4c4502762e8d8289f87952d45ad \
//                                     -Dsonar.exclusions=target/** \
//                                     -Dsonar.pitest.mode=reuseReport"
//                 }
                
//                 timeout(time: 2, unit: 'MINUTES') {
//                     script {
//                         waitForQualityGate abortPipeline: true
//                     }
//                 }
//             }
 
//         }

//         stage('Vulnerability Scan - Docker') {
//             steps {
//                 parallel(
//                     "Dependency Scan": {
//                         sh "mvn dependency-check:check"
//                     },
//                     "Trivy Scan": {
//                         sh "bash trivy-docker-image-scan.sh"
//                     },
//                     "OPA Conftest":{
//                         sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
//                     }   	
                
//                 )
//             }
//         }


//         stage('Docker Build and Push') {
            

//             steps {
//                 withDockerRegistry([credentialsId: "docker-hub-token", url: ""]) {
//                     sh 'printenv'
//                     sh 'docker build -t youda313/numeric-app:""$GIT_COMMIT"" .'
//                     sh 'docker push youda313/numeric-app:""$GIT_COMMIT""'
//                 }

//             }
//         }

//         stage('Vulnerability Scan - Kubernetes') {
//             steps {
//                 parallel(
//                     "OPA Scan": {
//                         sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
//                     },
//                     "Kubesec Scan": {
//                         sh "bash kubesec-scan.sh"
//                     },
//                     "Trivy Scan": {
//                         sh "bash trivy-k8s-scan.sh"
//                     }
//                 )
//             }
//         }

// // Note these should be 2 different stages instead of parallel
//         stage('K8S Deployment - DEV') {
//             steps {
//                 parallel(
//                     "Deployment": {
//                         withKubeConfig([credentialsId: 'kubeconfig']) {
//                         sh "bash k8s-deployment.sh"
//                         }
//                     },
//                     "Rollout Status": {
//                         withKubeConfig([credentialsId: 'kubeconfig']) {
//                         sh "bash k8s-deployment-rollout-status.sh"
//                         }
//                     }
//                 )
//             }
//         }


//         stage('Integration Tests - DEV') {
//             steps {
//                 script {
//                     try {
//                         withKubeConfig([credentialsId: 'kubeconfig']) {
//                         sh "bash integration-test.sh"
//                         }
//                     } catch (e) {
//                         withKubeConfig([credentialsId: 'kubeconfig']) {
//                         sh "kubectl -n default rollout undo deploy ${deploymentName}"
//                         }
//                         throw e
//                     }
//                 }
//             }
//         }

//         stage('OWASP ZAP - DAST') {
//             steps {
//                 withKubeConfig([credentialsId: 'kubeconfig']) {
//                 sh 'bash zap.sh'
//                 }
//             }
//         }

        stage('Testing Slack - 1') {
            steps {
                sh 'exit 0'
            }
        }

        // stage('Testing Slack - Error Stage') {
        //     steps {
        //         sh 'exit 0'
        //     }
        // }

    }
    post { 
        always { 
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            //pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            //publish the ZAP report inside jenkins left slide menu
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report', useWrapperFileDirectly: true])
 		    //Use sendNotifications.groovy from shared library and provide current build result as parameter 
            sendNotification currentBuild.result
        }
        //success{}
        //failure{}
    }
}
