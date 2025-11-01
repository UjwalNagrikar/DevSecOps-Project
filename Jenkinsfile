pipeline {
    agent any

    stages {

        stage('SonarQube Analysis') {
            steps {
                script {
                    scannerHome = tool 'SonarScanner'
                }

                withSonarQubeEnv('SonarServer') {
                    sh """
                    ${scannerHome}/bin/sonar-scanner \
                    -Dsonar.projectKey=myproject \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://34.100.168.24:9000 \
                    -Dsonar.login=squ_68ad352f43fcd4630c8e17246433e073e6ea6bc4
                    """
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '''--scan .''', odcInstallation: 'dc'
                dependencyCheckPublisher pattern: '**/dependency-check-report.html'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy fs . > trivy-report.txt"
            }
        }

        stage('Sonar Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Deployment') {
            steps {
                sh "docker ps -q --filter 'name=myproject' | grep -q . && docker stop myproject && docker rm myproject || echo 'No container to remove'"
                sh "docker images -q myproject | grep -q . && docker rmi -f myproject || echo 'No image to remove'"
                sh "docker build -t myproject ."
                sh "docker run -d -p 8081:80 --name myproject myproject"
            }
        }
    }
}
