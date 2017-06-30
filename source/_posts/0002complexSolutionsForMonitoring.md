---
  title: Complex Monitoring Solutions
  categories: Supervisor
  tags:
    - docker
    - supervisor
    - monitoring
---

# 1. Complex Solutions For Monitoring

Till now I have collected the following solutions:

- cAdvisor + influxDB + grafana
- collectd + influxDB + grafana
- Prometheus
- Cloud Insight
- Graphite
- Zabbix
- Fluentd
- heapster (k8s sub-project)

# 2. Zabbix

{% note info %}

Zabbix 是由 Alexei Vladishev 开发的一种网络监视、管理系统，基于 Server-Client 架构。可用于监视各种网络服务、服务器和网络机器等状态。

<a href="https://github.com/monitoringartist/zabbix-docker-monitoring">Ref: Zabbix Docker Monitoring</a>

{% endnote %}


## 2.1 What to supervise

1. Available CPU
2. MEM
3. blkio
4. net container metrics
5. containers config details: ip address, host name, etc.

## 2.2 Zabbix Architecture

![Zabbix Architecture](/uploads/0002-archi-zabbix.png)


## 2.3 Deployment

### 2.3.1 Create Data volume

~~~bash
docker run -d -v /var/lib/mysql --name zabbix-db-storage busybox:latest
~~~

### 2.3.2 Start Maria DB for Zabbix

{% note info %} default 1GB innodb_buffer_pool_size is used {% endnote %}

~~~bash
docker run \
    -d \
    --name zabbix-db \
    -v /backups:/backups \
    -v /etc/localtime:/etc/localtime:ro \
    --volumes-from zabbix-db-storage \
    --env="MARIADB_USER=zabbix" \
    --env="MARIADB_PASS=zabbix" \
    monitoringartist/zabbix-db-mariadb
~~~

### 2.3.3 Start Zabbix linked to started DB

~~~bash
docker run \
    -d \
    --name zabbix \
    -p 8888:80 \
    -p 10051:10051 \
    -v /etc/localtime:/etc/localtime:ro \
    --link zabbix-db:zabbix.db \
    --env="ZS_DBHost=zabbix.db" \
    --env="ZS_DBUser=zabbix" \
    --env="ZS_DBPassword=zabbix" \
    monitoringartist/zabbix-xxl:latest
~~~

### 2.3.4 Verify Login

![Zabbix Login](0002-zabbix-login.png)

Normally we can see this page on http://<ip address>:8888 now, and the login information as follows:

{% note success %}
Username: admin
Password: zabbix
{% endnote %}

### 2.3.5 Get Server done with docker-compose

To automatise the listing process we created a docker-compose.yml:

~~~yaml

version: '2'
services:
  zabbix-server:
    image: monitoringartist/zabbix-xxl:latest
    container_name: zabbix
    networks:
      zabbix_net:
        ipv4_address: 10.0.78.10
    environment:
      - ZS_DBHost=10.0.78.9
      - ZS_DBUser=zabbix
      - ZS_DBPassword=zabbix
    depends_on:
      - zabbix-db
    volumes:
      - /etc/localtime:/etc/localtime
    ports:
      - 8888:80
      - 10051:10051
  zabbix-db:
    image: monitoringartist/zabbix-db-mariadb
    container_name: zabbix-db
    volumes_from:
      - zabbix-db-storage
    depends_on:
      - zabbix-db-storage
    environment:
      - MARIADB_USER=zabbix
      - MARIADB_PASS=zabbix
    volumes:
      - /backups:/backups
      - /etc/localtime:/etc/localtime
    networks:
      zabbix_net:
        ipv4_address: 10.0.78.9
  zabbix-db-storage:
    image: busybox:latest
    container_name: zabbix-db-storage
    volumes:
      - /var/lib/mysql


networks:
  zabbix_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 10.0.78.0/24
          gateway: 10.0.78.1

#docker-compose.yml
~~~

###2.3.6 Other functions of Server side

~~~bash
# Backup of DB Zabbix - configuration data only, no item history/trends
docker exec \
    -ti zabbix-db \
    /zabbix-backup/zabbix-mariadb-dump -u zabbix -p my_password -o /backups

# Full backup of Zabbix DB
docker exec \
    -ti zabbix-db \
    bash -c "\
    mysqldump -u zabbix -pmy_password zabbix | \
    bzip2 -cq9 > /backups/zabbix_db_dump_$(date +%Y-%m-%d-%H.%M.%S).sql.bz2"

# Restore Zabbix DB
# remove zabbix server container
docker rm -f zabbix
# restore data from dump (all current data will be dropped!!!)
docker exec -i zabbix-db sh -c 'bunzip2 -dc /backups/zabbix_db_dump_2016-05-25-02.57.46.sql.bz2 \
 | mysql -uzabbix -p --password=my_password zabbix'
# run zabbix server again
docker run ...
~~~

### 2.3.6 Zabbix Agent

This figure show how it works:

![Zabbix Dockbix agent](/uploads/0002-dockbix-agent-xxl-schema.png)

~~~bash
docker run \
  --name=dockbix-agent-xxl \
  --net=host \
  --privileged \
  -v /:/rootfs \
  -v /var/run:/var/run \
  --restart unless-stopped \
  -e "ZA_Server=10.9.41.131" \
  -e "ZA_ServerActive=10.9.41.131" \
  -d monitoringartist/dockbix-agent-xxl-limited:latest
~~~

### 2.3.7 Discovery

![Zabbix Server discovery](/uploads/0002-zabbix-discovery.png)

Then:
![](/uploads/0002-group-1.png)
![](/uploads/0002-group-2.png)
