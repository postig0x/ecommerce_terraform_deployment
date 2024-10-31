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
        sh '''#!/bin/bash
        source backend/venv/bin/activate
        pip install pytest-django
        python backend/manage.py makemigrations
        python backend/manage.py migrate
        pytest backend/account/tests.py --verbose --junit-xml test-reports/results.xml
        '''
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

    stage('Terraform Destroy') {
      when {
        branch 'main'
      }
      steps {
        dir('Terraform') {
          sh '''#!/bin/bash
          source /etc/environment
          terraform destroy -auto-approve -var="default_key_name=${default_key_name}" -var="ssh_key=${ssh_key}"
          '''
        }
      }
    }
     
    stage('Plan') {
      when {
        branch 'main'
      }
      // steps {
      //   withCredentials([
      //     string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
      //     string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
      //   ]) {
      //     dir('Terraform') {
      //       sh 'terraform plan -out plan.tfplan -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}"' 
      //     }
      //   }
      // }
      steps {
        dir('Terraform') {
          sh '''#!/bin/bash
          source /etc/environment
          terraform plan -out plan.tfplan -var="default_key_name=${default_key_name}" -var="ssh_key=${ssh_key}"
          '''
        }
      }
    }

    stage('Apply') {
      when {
        branch 'main'
      }
      steps {
        dir('Terraform') {
          sh '''#!/bin/bash
          source /etc/environment
          terraform apply "plan.tfplan" -var="default_key_name=${default_key_name}" -var="ssh_key=${ssh_key}"
          ''' 
        }
      }  
    }       
  }
}
