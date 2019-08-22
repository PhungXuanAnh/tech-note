clean:
	docker-compose down
	sudo rm -rf mysql-1/mysql-data/* \
		mysql-1/mysql-logs/*.log \
		mysql-1/mysql-logs/*.index \
		mysql-1/mysql-logs/bin/* \
		mysql-1/mysql-logs/relay/*
	sudo rm -rf mysql-2/mysql-data/* \
		mysql-2/mysql-logs/mysql-* \
		mysql-2/mysql-logs/*.log \
		mysql-2/mysql-logs/*.index \
		mysql-2/mysql-logs/bin/* \
		mysql-2/mysql-logs/relay/*

chmod:
	sudo chmod -R 777 mysql-*/mysql-logs

