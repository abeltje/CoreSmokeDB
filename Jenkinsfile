#! Groovy

pipeline {
    agent { label 'perl5smokedb' }
    environment {
        PGHOST='fidodbmaster'
        PERL_CPANM_HOME='/tmp/.cpanm'
    }
    stages {
        stage('Build_and_Test') {
            steps {
                script { echo "Building and testing branch: " + scm.branches[0].name }
                sh '''
cpanm --notest -L local --installdeps .
cpanm --notest -L local TAP::Formatter::JUnit Test::NoWarnings Plack Daemon::Control Starman
prove -Ilocal/lib/perl5 --formatter=TAP::Formatter::JUnit --timer -wl t/ > testout.xml
                '''
                archiveArtifacts artifacts: 'local/**, lib/**, environments/**, config.yml, tsgateway, templates/**, public/**'
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
                    branches: [[name: '*/main']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[
                        $class: 'RelativeTargetDirectory',
                        relativeTargetDir: 'configs'
                    ]],
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: '6ad81623-70f5-4d1c-8631-9015178ff4c9',
                        url: 'ssh://git@source.test-smoke.org:9999/~/ztreet-configs'
                    ]]
                ])
                sh '''
cp -v configs/CoreSmokeDB/test.yml deploy/environments/
cp -v configs/CoreSmokeDB/smokedb.yml deploy/environments/
cp -v configs/CoreSmokeDB/preview.yml deploy/environments/
cp -v configs/CoreSmokeDB/production.yml deploy/environments/
chmod +x deploy/local/bin/*
                '''
                archiveArtifacts artifacts: 'deploy/**'
                script {
                    echo "Merged configs for: ${env.BRANCH_NAME}" + scm.branches[0].name
                }
            }
        }
        stage('DeployPreview') {
            when {
                // branch 'preview'
                expression {
                    echo "BRANCH_NAME is ${scm.branches[0].name}"
                    return scm.branches[0].name == "preview"
                }
            }
            steps {
//                script {
//                    def usrinput = input message: "Deploy or Abort ?", ok: "Deploy!"
//                }
                sh 'chmod +x deploy/local/bin/*'
                sh 'touch deploy/tsgateway'
                sshagent(['ssh-deploy']) {
                    sh '''
/usr/bin/deploy -av deploy/ perl5smokedb.fritz.box:/var/lib/www/CoreSmokeDB.preview/
/usr/bin/restart-remote perl5smokedb.fritz.box perl5smokedb-preview
                        '''
                }
            }
        }
        stage('DeployProduction') {
            when {
                //branch 'master'
                expression {
                    echo "BRANCH_NAME is ${scm.branches[0].name}"
                    return scm.branches[0].name == "master"
                }
            }
            steps {
                script {
                    def usrinput = input message: "Deploy or Abort ?", ok: "Deploy!"
                }
                sh 'chmod +x deploy/local/bin/*'
                sh 'touch deploy/tsgateway'
                sshagent(['ssh-deploy']) {
                    sh '''
/usr/bin/deploy -av deploy/ perl5smokedb.fritz.box:/var/lib/www/CoreSmokeDB/
/usr/bin/restart-remote perl5smokedb.fritz.box perl5smokedb
                       '''
                }
            }
        }
    }
}

// # vim: expandtab shiftwidth=4 softtabstop=4
