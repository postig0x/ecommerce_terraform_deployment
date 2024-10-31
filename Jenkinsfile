pipeline {
  agent any
  stages {
    stage ('Build') {
      when {
        branch 'main'
      }
      steps {
        dir('backend') {
          sh '''#!/bin/bash
          python3.9 -m venv venv
          source venv/bin/activate
          pip install -r requirements.txt
          '''
        }
        dir('frontend') {
          sh '''#!/bin/bash
          # install node if doesn't exist
          if ! command -v node &> /dev/null
          then
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt install -y nodejs
            sleep 2
          fi
          
          npm i
          export NODE_OPTIONS=--openssl-legacy-provider
          '''
        }
      }
    }
    stage ('Test') {
      when {
        branch 'main'
      }
      steps {
        dir('backend') {
          sh '''#!/bin/bash
          source venv/bin/activate
          pip install pytest-django
          python backend/manage.py makemigrations
          python backend/manage.py migrate
          pytest backend/account/tests.py --verbose --junit-xml test-reports/results.xml
          '''
        } 
      }
    }
   
    stage('Init') {
      when {
        branch 'main'
      }
      steps {
        dir('Terraform') {
          sh 'terraform init' 
        }
       }
    } 
     
    stage('Plan') {
      when {
        branch 'main'
      }
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
          string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
        ]) {
          dir('Terraform') {
            sh 'terraform plan -out plan.tfplan -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}"' 
          }
        }
      }     
    }
    stage('Apply') {
      when {
        branch 'main'
      }
      steps {
        dir('Terraform') {
          sh 'terraform apply plan.tfplan' 
        }
      }  
    }       
  }
}
