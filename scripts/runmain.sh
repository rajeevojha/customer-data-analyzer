export PGPASSWORD="Sw33t0Rang"
psql -h ${aws_db_instance.pg.address} -p 5432 -U postgres -d customers -f /home/ubuntu/app/scripts/init-db.sql >> /var/log/startup.log 2>&1
echo "PSQL exit: $?" >> /var/log/startup.log
cd /home/ubuntu/app/node
echo "current dir is $ls" >> /var/log/startup.log
echo "Starting app..." >> /var/log/startup.log
cat << SCRIPT > start-app.sh
#!/bin/bash
export PGHOST="${aws_db_instance.pg.address}"
export PGPASSWORD="postgres123"
cd /home/ubuntu/app/node
node apppg.js >> /var/log/app/startup.log 2>&1
SCRIPT
chmod +x start-app.sh
nohup ./start-app.sh &
sleep 5
ps -ef | grep node >> /var/log/startup.log 2>&1
netstat -tuln | grep 3000 >> /var/log/startup.log 2>&1
echo "App started $(date)" >> /var/log/startup.log
