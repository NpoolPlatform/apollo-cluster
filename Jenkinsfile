pipeline {
  agent any
  environment {
    GOPROXY = 'https://goproxy.cn,direct'
  }
  tools {
    go 'go'
  }
  stages {
    stage('Clone apollo cluster') {
      steps {
        git(url: scm.userRemoteConfigs[0].url, branch: '$BRANCH_NAME', changelog: true, credentialsId: 'KK-github-key', poll: true)
      }
    }

    stage('Check deps tools') {
      steps {
        script {
          if (!fileExists("/usr/bin/helm")) {
            sh 'mkdir -p $HOME/.helm'
            if (!fileExists("$HOME/.helm/.helm-src")) {
              sh 'git clone https://github.com/helm/helm.git $HOME/.helm/.helm-src'
            }
            sh 'cd $HOME/.helm/.helm-src; git checkout release-3.7; make; cp bin/helm /usr/bin/helm'
            sh 'helm version'
          }
        }
      }
    }

    stage('Switch to current cluster') {
      steps {
        sh 'cd /etc/kubeasz; ./ezctl checkout $TARGET_ENV'
      }
    }

    stage('Build apollo image') {
      when {
        expression { BUILD_TARGET == 'true' }
      }
      steps {
        sh(returnStdout: true, script: '''
          images=`docker images | grep entropypool | grep apollo | awk '{ print $3 }'`
          for image in $images; do
            docker rmi $image
          done
        '''.stripIndent())
        sh 'mkdir -p service-config/.docker-tmp; cp /usr/bin/consul service-config/.docker-tmp'
        sh 'cd service-config; docker build -t uhub.service.ucloud.cn/entropypool/apollo-configservice:1.9.1.2 .'
        sh 'mkdir -p service-admin/.docker-tmp; cp /usr/bin/consul service-admin/.docker-tmp'
        sh 'cd service-admin; docker build -t uhub.service.ucloud.cn/entropypool/apollo-adminservice:1.9.1.2 .'
        sh 'mkdir -p service-portal/.docker-tmp; cp /usr/bin/consul service-portal/.docker-tmp'
        sh 'cd service-portal; docker build -t uhub.service.ucloud.cn/entropypool/apollo-portal:1.9.1.2 .'
      }
    }

    stage('Release apollo image') {
      when {
        expression { RELEASE_TARGET == 'true' }
      }
      steps {
        sh(returnStdout: true, script: '''
          set +e
          while true; do
            docker push uhub.service.ucloud.cn/entropypool/apollo-configservice:1.9.1.2
            if [ $? -eq 0 ]; then
              break
            fi
            sleep 5
          done
          while true; do
            docker push uhub.service.ucloud.cn/entropypool/apollo-portal:1.9.1.2
            if [ $? -eq 0 ]; then
              break
            fi
            sleep 5
          done
          while true; do
            docker push uhub.service.ucloud.cn/entropypool/apollo-adminservice:1.9.1.2
            if [ $? -eq 0 ]; then
              break
            fi
            sleep 5
          done
          set -e
        '''.stripIndent())
      }
    }

    stage('Deploy apollo cluster and portal') {
      when {
        expression { DEPLOY_TARGET == 'true' }
      }
      steps {
        sh 'helm repo add apollo https://www.apolloconfig.com/charts'
        sh 'helm upgrade apollo-service --namespace kube-system -f values.service.yaml ./chart-service || helm install apollo-service --namespace kube-system -f values.service.yaml ./chart-service'
        sh 'TARGET_ENV=$TARGET_ENV envsubst < values.portal.yaml > .values.portal.yaml'
        sh 'helm upgrade apollo-portal --namespace kube-system -f .values.portal.yaml ./chart-portal || helm install apollo-portal -n kube-system -f .values.portal.yaml ./chart-portal'
        sh 'rm -rf .values.portal.yaml'
      }
    }

    stage('Config apollo') {
      when {
        expression { CONFIG_TARGET == 'true' }
      }
      steps {
        sh 'rm .apollo-base-config -rf'
        sh 'git clone https://github.com/NpoolPlatform/apollo-base-config.git .apollo-base-config'
        sh 'cd .apollo-base-config; ./apollo-appid-config.sh $APP_ID $TARGET_ENV'
      }
    }
  }
  post('Report') {
    fixed {
      script {
        sh(script: 'bash $JENKINS_HOME/wechat-templates/send_wxmsg.sh fixed')
     }
      script {
        // env.ForEmailPlugin = env.WORKSPACE
        emailext attachmentsPattern: 'TestResults\\*.trx',
        body: '${FILE,path="$JENKINS_HOME/email-templates/success_email_tmp.html"}',
        mimeType: 'text/html',
        subject: currentBuild.currentResult + " : " + env.JOB_NAME,
        to: '$DEFAULT_RECIPIENTS'
      }
     }
    success {
      script {
        sh(script: 'bash $JENKINS_HOME/wechat-templates/send_wxmsg.sh successful')
     }
      script {
        // env.ForEmailPlugin = env.WORKSPACE
        emailext attachmentsPattern: 'TestResults\\*.trx',
        body: '${FILE,path="$JENKINS_HOME/email-templates/success_email_tmp.html"}',
        mimeType: 'text/html',
        subject: currentBuild.currentResult + " : " + env.JOB_NAME,
        to: '$DEFAULT_RECIPIENTS'
      }
     }
    failure {
      script {
        sh(script: 'bash $JENKINS_HOME/wechat-templates/send_wxmsg.sh failure')
     }
      script {
        // env.ForEmailPlugin = env.WORKSPACE
        emailext attachmentsPattern: 'TestResults\\*.trx',
        body: '${FILE,path="$JENKINS_HOME/email-templates/fail_email_tmp.html"}',
        mimeType: 'text/html',
        subject: currentBuild.currentResult + " : " + env.JOB_NAME,
        to: '$DEFAULT_RECIPIENTS'
      }
     }
    aborted {
      script {
        sh(script: 'bash $JENKINS_HOME/wechat-templates/send_wxmsg.sh aborted')
     }
      script {
        // env.ForEmailPlugin = env.WORKSPACE
        emailext attachmentsPattern: 'TestResults\\*.trx',
        body: '${FILE,path="$JENKINS_HOME/email-templates/fail_email_tmp.html"}',
        mimeType: 'text/html',
        subject: currentBuild.currentResult + " : " + env.JOB_NAME,
        to: '$DEFAULT_RECIPIENTS'
      }
     }
  }
}
