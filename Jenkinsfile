
pipeline {

    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        AWS_ACCOUNT_ID = '036253061913'

        ECR_REPOSITORY = 'devops'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}"

        IMAGE_TAG = "${BUILD_NUMBER}"
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
                    echo "Building Docker image..."

                    docker build \
                      -t ${IMAGE_URI}:${IMAGE_TAG} \
                      ./app

                    echo "Docker image built successfully:"
                    docker images | grep ${ECR_REPOSITORY}
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-ecr']
                ]) {
                    sh '''
                        echo "Checking AWS credentials..."

                        aws sts get-caller-identity

                        echo "Logging in to Amazon ECR..."

                        aws ecr get-login-password \
                          --region ${AWS_REGION} \
                        | docker login \
                          --username AWS \
                          --password-stdin ${ECR_REGISTRY}

                        echo "ECR login successful."
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    echo "Pushing image to ECR..."

                    docker push ${IMAGE_URI}:${IMAGE_TAG}

                    echo "Image pushed successfully:"
                    echo "${IMAGE_URI}:${IMAGE_TAG}"
                '''
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                sh '''
                    echo "Updating Kubernetes image tag..."

                    sed -i "s/newTag:.*/newTag: ${IMAGE_TAG}/" \
                      k8s/kustomization.yaml

                    echo "Updated Kubernetes manifest:"
                    grep "newTag:" k8s/kustomization.yaml
                '''
            }
        }

        stage('Commit and Push Git') {
            steps {
                sshagent(['github-ssh']) {
                    sh '''
                        echo "Configuring Git..."

                        git config user.name "Jenkins"
                        git config user.email "jenkins@localhost"

                        echo "Git remote before update:"
                        git remote -v

                        echo "Changing GitHub remote to SSH..."

                        git remote set-url origin \
                          git@github.com:ma6075707-blip/Devops-project.git

                        echo "Testing GitHub SSH connection..."

                        ssh -o StrictHostKeyChecking=no \
                          -T git@github.com || true

                        git add k8s/kustomization.yaml

                        git commit \
                          -m "Update image tag to ${IMAGE_TAG}" || true

                        echo "Pushing changes to GitHub..."

                        git push origin HEAD:main

                        echo "GitHub push successful."
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "=========================================="
            echo "CI Pipeline completed successfully!"
            echo "Image: ${IMAGE_URI}:${IMAGE_TAG}"
            echo "=========================================="
        }

        failure {
            echo "=========================================="
            echo "CI Pipeline failed!"
            echo "Check the stage above for the error."
            echo "=========================================="
        }
    }
}

