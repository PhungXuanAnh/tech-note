#! /bin/bash

export $(cat .vscode/local_files/sonarqube/scripts/scan.env | xargs)

~/Downloads/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner \
    -Dsonar.projectKey=$PROJECT_KEY \
    -Dsonar.sources=$SOURCE_DIR \
    -Dsonar.inclusions="**/*.py" \
    -Dsonar.exclusions="**/tests/**, **/migrations/**,  **/whitelabels/**, **/.*/**, **/*.css, **/*.js" \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=$TOKEN \
    -Dsonar.login=admin \
    -Dsonar.password=Sona@1234567 \
    -Dsonar.newCode.referenceBranch=master \
    -Dsonar.python.version=$PYTHON_VERION
