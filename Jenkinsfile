pipeline {
  agent any
  tools {
    go 'go'
  }
  environment {
    GOPROXY = 'https://goproxy.cn,direct'
  }
  stages {

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

    stage('Helm install apollo-service') {
      steps {
        sh 'echo "configdb:\n" > ./apollo-service.values.yaml'
        sh "echo \"  host: \"$MYSQL_HOST\"\n\" >> ./apollo-service.values.yaml"
        sh "echo \"  dbName: ApolloConfigDB\n\" >> ./apollo-service.values.yaml"
        sh "echo \"  connectionStringProperties: characterEncoding=utf8&useSSL=false\n\" >> ./apollo-service.values.yaml"
        sh "echo \"  service:\n\">> ./apollo-service.values.yaml"
        sh "echo \"    enabled: false\">> ./apollo-service.values.yaml"
        sh "echo \"configService:\n\" >> ./apollo-service.values.yaml"
        sh "echo \"  replicaCount: $CFS_COPIES\n\" >> ./apollo-service.values.yaml"
        sh "echo \"adminService:\n\" >> ./apollo-service.values.yaml"
        sh "echo \"  replicaCount: $ADM_COPIES\n\" >> ./apollo-service.values.yaml"
        sh "echo \"\n\" >> ./apollo-service.values.yaml"
        sh "helm uninstall $SVC_NAME-svc -n $K8S_NAMESPACE || true"
        sh "helm install $SVC_NAME-svc -f ./apollo-service.values.yaml -n $K8S_NAMESPACE ./apollo-service"
      }
    }

    stage('Install apollo-portal') {
      steps {
        sh "helm uninstall $SVC_NAME-portal -n $K8S_NAMESPACE || true"
        sh "helm install $SVC_NAME-portal \
    --set configdb.host=\"$MYSQL_HOST\" \
    --set configdb.userName=root \
    --set configdb.password='' \
    --set configdb.service.enabled=false \
    --set config.envs=\"dev\\,pro\" \
    --set config.metaServers.dev=http://$SVC_NAME-portal-apollo-configservice:8080 \
    --set config.metaServers.pro=http://$SVC_NAME-portal-apollo-configservice:8080 \
    --set replicaCount=1 \
    -n $K8S_NAMESPACE \
    ./apollo-portal"
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
