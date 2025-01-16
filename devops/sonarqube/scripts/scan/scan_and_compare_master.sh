#! /bin/bash

export $(cat .vscode/local_files/sonarqube/scripts/scan.env | xargs)

current_branch=$(git branch --show-current)

if [ "$current_branch" == "master" ]; then
    echo "You are on master branch. Please checkout to a feature branch."
    exit 1
fi

git checkout master
git pull
~/Downloads/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner \
    -Dsonar.projectKey=$PROJECT_KEY \
    -Dsonar.sources=$SOURCE_DIR \
    -Dsonar.inclusions="**/*.py" \
    -Dsonar.exclusions="**/tests/**, **/migrations/**,  **/whitelabels/**, **/.*/**, **/*.css, **/*.js" \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=$TOKEN \
    -Dsonar.python.version=$PYTHON_VERION
sleep 5
git checkout -
~/Downloads/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner \
    -Dsonar.projectKey=$PROJECT_KEY \
    -Dsonar.sources=$SOURCE_DIR \
    -Dsonar.inclusions="**/*.py" \
    -Dsonar.exclusions="**/tests/**, **/migrations/**,  **/whitelabels/**, **/.*/**, **/*.css, **/*.js" \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=$TOKEN \
    -Dsonar.python.version=$PYTHON_VERION
sleep 5
google-chrome http://localhost:9000/dashboard?id=$PROJECT_KEY