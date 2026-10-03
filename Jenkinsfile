
pipeline {

    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        AWS_PROFILE = 'user-terraform'

        ECR_REPOSITORY = 'devops'
        AWS_ACCOUNT_ID = '036253061913'

        IMAGE_TAG = "${BUILD_NUMBER}"

        IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t ${IMAGE_URI}:${IMAGE_TAG} \
                      ./app
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password \
                      --region ${AWS_REGION} \
                      --profile ${AWS_PROFILE} \
                    | docker login \
                      --username AWS \
                      --password-stdin ${IMAGE_URI}
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    docker push ${IMAGE_URI}:${IMAGE_TAG}
                '''
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                sh '''
                    sed -i "s/newTag:.*/newTag: ${IMAGE_TAG}/" k8s/kustomization.yaml

                    echo "Updated Kubernetes image tag:"
                    grep "newTag:" k8s/kustomization.yaml
                '''
            }
        }

        stage('Commit and Push Git') {
            steps {
                sh '''
                    git config user.name "Jenkins"
                    git config user.email "jenkins@localhost"

                    git add k8s/kustomization.yaml

                    git commit -m "Update image tag to ${IMAGE_TAG}" || true

                    git push origin HEAD:main
                '''
            }
        }
    }
}

