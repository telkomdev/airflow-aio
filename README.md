# airflow-aio
[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/telkomdev/airflow-aio/blob/main/LICENSE)

Deploy Airflow on Bare-metal with ease

## Prerequisites
- bash
- ca-certificates
- curl

## Quick Install
```shell
$ curl -H 'Cache-Control: no-cache' -ko - 'https://raw.githubusercontent.com/telkomdev/airflow-aio/main/quick-install.sh' | bash
```

## Default Admin User
```
role     : Admin
username : admin
password : admin
```

## MySQL DB Configuration
```
host     : localhost
port     : 3306
database : airflow_db
username : airflow_user
password : AirflowDBPass
```

## Port Configuration
```
Nginx (reverse proxy) : 80 (http)
Airflow webserver     : 8080 (http)
```

## Airflow Configuration
If you wish to modify & use custom configuration, all Airflow configuration, logs, data are located on `/root/airflow`


### Notes
**Tested running well on Ubuntu 22.04 LTS**
