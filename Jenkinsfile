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
            sh 'cd $HOME/.helm/.helm-src; make; cp bin/helm /usr/bin/helm'
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
        sh 'mkdir -p service-config/.docker-tmp; cp /usr/bin/consul service-config/.docker-tmp'
        sh 'cd service-config; docker build -t entropypool/apollo-configservice:1.9.1 .'
        sh 'mkdir -p service-admin/.docker-tmp; cp /usr/bin/consul service-admin/.docker-tmp'
        sh 'cd service-admin; docker build -t entropypool/apollo-adminservice:1.9.1 .'
        sh 'mkdir -p service-portal/.docker-tmp; cp /usr/bin/consul service-portal/.docker-tmp'
        sh 'cd service-portal; docker build -t entropypool/apollo-portal:1.9.1 .'
      }
    }

    stage('Release apollo image') {
      when {
        expression { RELEASE_TARGET == 'true' }
      }
      steps {
        sh 'export ALL_PROXY=socks5://172.16.31.128:10808; export HTTP_PROXY="socks5://172.16.31.128:10808"; export HTTPS_PROXY="socks5://172.16.31.128:10808"'
        sh(returnStdout: true, script: '''
          while true; do
            docker push entropypool/apollo-configservice:1.9.1
            if [ $? -eq 0 ]; then
              break
            fi
          done
          echo "configservice done"
        '''.stripIndent())
        sh(returnStdout: true, script: '''
          while true; do
            docker push entropypool/apollo-portal:1.9.1
            if [ $? -eq 0 ]; then
              break
            fi
          done
          echo "portal done"
        '''.stripIndent())
        sh(returnStdout: true, script: '''
          while true; do
            docker push entropypool/apollo-adminservice:1.9.1
            if [ $? -eq 0 ]; then
              break
            fi
          done
          echo "adminservice done"
        '''.stripIndent())
        sh 'unset HTTP_PROXY; unset HTTPS_PROXY; unset ALL_PROXY'
      }
    }

    stage('Deploy apollo cluster and portal') {
      when {
        expression { DEPLOY_TARGET == 'true' }
      }
      steps {
        sh 'helm upgrade apollo-service --namespace kube-system -f values.service.yaml ./chart-service || helm install apollo-service --namespace kube-system -f values.service.yaml ./chart-service'
        sh 'helm upgrade apollo-portal --namespace kube-system -f values.portal.yaml ./chart-portal || helm install apollo-portal --namespace kube-system -f values.portal.yaml ./chart-portal'
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
