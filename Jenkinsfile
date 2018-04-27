#! Groovy

pipeline {
    agent { label 'takkie' }
    stages {
        stage('Build_and_Test') {
            steps {
                script { echo "Building and testing branch: " + scm.branches[0].name }
		// CentOS doesn't have a carton-package
                sh 'cpanm -l local --installdeps .'
                sh 'cpanm -l local TAP::Formatter::JUnit'
                sh 'prove -Ilocal/lib/perl5 --formatter=TAP::Formatter::JUnit --timer -wl t/ > testout.xml'
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
                sh 'cp -v configs/CoreSmokeDB/test.yml deploy/environments/'
                sh 'cp -v configs/CoreSmokeDB/smokedb.yml deploy/environments/'
                sh 'chmod +x deploy/local/bin/*'
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
                sh 'rsync -e "ssh -i /var/lib/jenkins/.ssh/centos_rsa -l abeltje" -avP deploy/ takkie.fritz.box:CoreSmokeDB/'
            }
        }
        stage('DeployProduction') {
            when { branch 'master' }
            steps {
                script {
                    def usrinput = input message: "Deploy or Abort ?", ok: "Deploy!"
                }
            }
        }
    }
}
