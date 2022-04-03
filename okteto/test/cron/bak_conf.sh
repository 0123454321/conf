#!/bin/bash

one_path="/mnt/data/oneindex-j/one.php"

echo "---------------备份CR数据库----------------"
php ${one_path} upload:file  /mnt/data/cr/cloudreve.db  /BAK_SERVER/Okteto/CR/db/cloudreve_$(date +%Y%m%d%H%M).db

