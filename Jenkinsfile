pipeline {
    agent any

    environment {
        IMAGE_NAME="${PARAM_IMAGE_NAME}"
        TAG_NAME="${PARAM_TAG_NAME}"
        DOCKERHUB_ID="${PARAM_DOCKERHUB_ID}"
        DOCKERHUB_PASSWORD=credentials('DOCKERHUB_PW')
        AWS_ACCESS_KEY=credentials('aws_access_key')
        AWS_SECRET_KEY=credentials('aws_secret_key')

    }

    stages {
        stage('Build') {
            
            steps {
                sh 'docker build -t  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME .'
                sh 'docker rm -f  $IMAGE_NAME'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run -dti  --name $IMAGE_NAME   -p 80:80  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME'
                sh 'sleep 5'
                sh 'curl -I http://172.17.0.1'
        
            }
        }
        stage('clear container') {
            steps {
                sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
                '''       
            }
        }
        stage('Release') {
            steps {
                sh '''
                echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
                docker push  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME
                '''
        
            }
        }
        stage('deploy staging') {
            steps {
                sh '''
                cd
                cd staging
                terraform init \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_staging.tfvars"
                terraform plan \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_staging.tfvars"
                terraform apply -auto-approve \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_staging.tfvars"
                cat infos_ec2.txt
                '''
        
            }
        }
        stage('deploy review') {
            steps {
                sh '''
                cd
                cd review
                terraform init \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_review.tfvars"
                terraform plan \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_review.tfvars"
                terraform apply -auto-approve \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_review.tfvars"
                cat infos_ec2.txt
                '''
        
            }
        }
        stage('deploy prod') {
            steps {
                sh '''
                cd
                cd prod
                terraform init \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_prod.tfvars"
                terraform plan \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_prod.tfvars"
                terraform apply -auto-approve \
                  -var 'AWS_ACCESS_KEY=$(AWS_ACCESS_KEY)' \
                  -var 'AWS_SECRET_KEY=$(AWS_SECRET_KEY)' \
                  -var-file="env_prod.tfvars"
                cat infos_ec2.txt
                '''
        
            }
        }
       
        
    }
}
