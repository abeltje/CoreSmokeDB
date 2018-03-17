#! Groovy

pipeline {
    agent any
    stages {
        stage('Build_and_Test') {
            steps {
                script { echo "Building and testing branch: " + scm.branches[0].name }
                sh 'carton install'
                sh 'cpanm --notest -L local Test::NoWarnings Plack Daemon::Control Starman'
                sh 'prove -Ilocal/lib/perl5 --formatter=TAP::Formatter::JUnit --timer -wl t/ > testout.xml'
                archiveArtifacts artifacts: 'local/**, lib/**, environments/**, config.yml, templates/**, public/**'
            }
            post {
                changed {
                    junit 'testout.xml'
                }
            }
        }
        stage('MergeConfig') {
            steps {
                step([$class: 'WsCleanup'])
                unarchive  mapping: ['**': 'deploy/']
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[
                        $class: 'RelativeTargetDirectory',
                        relativeTargetDir: 'configs'
                    ]],
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: '11da4872-4de5-40b3-903e-3789faf557eb',
                        url: 'ssh://git@source.test-smoke.org:9999/~/ztreet-configs'
                    ]]
                ])
                sh 'cp -v configs/coresmokedb/*.yml deploy/environments/'
                sh 'chmod +x deploy/local/bin/*'
                archiveArtifacts artifacts: 'deploy/**'
            }
        }
        stage('DeployPreview') {
//            when { branch 'preview' }
            steps {
                script {
                    def usrinput = input message: "Deploy or Abort ?", ok: "Deploy!"
                }
                sh 'chmod +x deploy/local/bin/*'
                sh 'chmod +x deploy/bin/*'
                sh 'touch deploy/tsgateway'
                sh 'rsync -e 'ssh -i /var/lib/jenkins/keys/pnl/id_rsa -l abeltje' -avP deploy/ fidobackend.fritz.box:CoreSmokeDB/'
            }
        }
    }
}
