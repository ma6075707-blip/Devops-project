pipeline {

    agent any

    stages {

        stage('Test') {
            steps {
                echo 'Hello from Jenkins!'
            }
        }

        stage('Check Files') {
            steps {
                sh '''
                    echo "Current directory:"
                    pwd

                    echo "Project files:"
                    ls -la

                    echo "App directory:"
                    ls -la app

                    echo "Dockerfile:"
                    ls -la app/Dockerfile
                '''
            }
        }

    }
}

