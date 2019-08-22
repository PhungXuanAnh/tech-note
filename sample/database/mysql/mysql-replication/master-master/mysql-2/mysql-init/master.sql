-- Tao user 'replicator' co password '123456' va cap quyen slave
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
FLUSH PRIVILEGES;

-- Lenh sau hoan thanh mot vai thu cung thoi diem
-- 1. chi dinh server hien tai la slave cua server master
-- 2. cung cap cac thong tin login den server master
-- 3. cho server slave (server hien tai) biet duoc vi tri bat dau replicate, chinh la cac thong so MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=  107;
CHANGE MASTER TO MASTER_HOST='mysql-1',MASTER_USER='replicator',MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_CONNECT_RETRY=30;

-- Start slave
START SLAVE;