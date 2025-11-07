# NOTE: these commands are added to .vscode/local_files/Makefile

SONARQUBE_PROJECT_NAME := sona_viralize
sonarqube-start:
	scripts/increase_max_map_count.sh
	cd .vscode/local_files/sonarqube/ && \
	docker compose --project-name ${SONARQUBE_PROJECT_NAME} --env-file env_file.sonarqube up -d
	scripts/check_sona_is_up.sh
	google-chrome http://localhost:9000
	curl -u admin:admin -X POST "http://localhost:9000/api/users/change_password?login=admin&previousPassword=admin&password=Sona@1234567" ||:


sonarqube-scan: sonarqube-start
	scripts/scan/scan.sh

sonarqube-scan-and-compare-master:
	scripts/scan/scan_and_compare_master.sh

sonarqube-scan-and-debug:
	scripts/scan/scan_debug.sh