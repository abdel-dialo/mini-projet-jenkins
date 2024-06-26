/* import shared library */
@Library('shared-library')_
pipeline {
    agent any

    environment {
        IMAGE_NAME="${PARAM_IMAGE_NAME}"
        TAG_NAME="${PARAM_TAG_NAME}"
        SERVER_USER="${PARAM_SERVER_USER}"
        DOCKERHUB_ID="${PARAM_DOCKERHUB_ID}"
        DOCKERHUB_PASSWORD=credentials('DOCKERHUB_PW')
        SSH_PRIVATE_KEY=credentials('aws_key_paire')

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
                sh 'docker run -d  --name $IMAGE_NAME   -p 80:80  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME'
                sh 'sleep 5'
                sh 'curl -I http://172.17.0.1'
        
            }
        }
        stage('Clear container') {
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
    stage('deploy') {
       agent { 
                    docker { 
                            image 'jenkins/jnlp-agent-terraform'  
                    } 
              }
      stages {
        
        stage('Deploy review') {
          when { changeRequest () }
            steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir('review') {
                sh '''
                terraform init \
                  -var-file="env_review.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform plan \
                  -var-file="env_review.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform apply -auto-approve \
                  -var-file="env_review.tfvars" \
                  -var ssh_key_file="${SSH_PRIVATE_KEY}"
                export REVIEW_SERVER=$(awk '/PUBLIC_IP/ {sub(/^.* *PUBLIC_IP/,""); print $2}' infos_ec2.txt)
                chmod og= $SSH_PRIVATE_KEY
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$REVIEW_SERVER "docker login -u "$DOCKERHUB_ID" -p "$DOCKERHUB_PASSWORD""
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$REVIEW_SERVER "docker pull $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME"
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$REVIEW_SERVER "docker container rm -f $IMAGE_NAME || true"
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$REVIEW_SERVER "docker run --rm -d -p 80:80 --name ${IMAGE_NAME} $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME"
                '''
                }
              }
        
            }
        }
        stage('Deploy staging') { 
          when {
           expression { GIT_BRANCH == 'origin/main' }
           }         
            steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir('staging') {
                sh '''
                terraform init \
                  -var-file="env_staging.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform plan \
                  -var-file="env_staging.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform apply -auto-approve \
                  -var-file="env_staging.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                export STAGING_SERVER=$(awk '/PUBLIC_IP/ {sub(/^.* *PUBLIC_IP/,""); print $2}' infos_ec2.txt)
                chmod og= $SSH_PRIVATE_KEY
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$STAGING_SERVER "docker login -u "$DOCKERHUB_ID" -p "$DOCKERHUB_PASSWORD""
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$STAGING_SERVER "docker pull $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME"
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$STAGING_SERVER "docker container rm -f $IMAGE_NAME || true"
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$STAGING_SERVER "docker run --rm -d -p 80:80 --name ${IMAGE_NAME} $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME"
                 
                '''
                }
              }
            }
        }

        stage('Test staging') {   
          when {
           expression { GIT_BRANCH == 'origin/main' }
           }       
            steps {           
                dir('staging') {
                sh '''  
                export STAGING_SERVER=$(awk '/PUBLIC_IP/ {sub(/^.* *PUBLIC_IP/,""); print $2}' infos_ec2.txt)
                apk upgrade
                apk add curl
                curl "http://$STAGING_SERVER" | grep -i "Dimension" 
                '''
                }
              }
            }
        

        
        stage('Deploy prod') {
           when {
           expression { GIT_BRANCH == 'origin/main' }
           }
            steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir ('prod') {
                sh '''
                terraform init \
                  -var-file="env_prod.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform plan \
                  -var-file="env_prod.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform apply -auto-approve \
                  -var-file="env_prod.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                export PROD_SERVER=$(awk '/PUBLIC_IP/ {sub(/^.* *PUBLIC_IP/,""); print $2}' infos_ec2.txt)
                chmod og= $SSH_PRIVATE_KEY
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$PROD_SERVER "docker login -u "$DOCKERHUB_ID" -p "$DOCKERHUB_PASSWORD""
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$PROD_SERVER "docker pull $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME"
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$PROD_SERVER "docker container rm -f $IMAGE_NAME || true"
                ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no $SERVER_USER@$PROD_SERVER "docker run --rm -d -p 80:80 --name ${IMAGE_NAME} $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME"
                '''
                }
              }
        
            }
        }    
        
    
     stage('Test Prod') {
           when {
           expression { GIT_BRANCH == 'origin/main' }
           }
            steps {
              
                dir ('prod') {
                sh '''
                export PROD_SERVER=$(awk '/PUBLIC_IP/ {sub(/^.* *PUBLIC_IP/,""); print $2}' infos_ec2.txt)
                apk upgrade
                apk add curl
                curl "http://$PROD_SERVER" | grep -i "Dimension" 
                '''
                }
              }
         }
    }
    }
    }
    post {
    always {
      script {
        slackNotifier currentBuild.result
      }
    }  
  }

}
