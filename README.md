# airflow-aio
Deploy Airflow on Bare-metal with ease

## Quick Install
```shell
$ curl -H 'Cache-Control: no-cache' -ko - 'https://raw.githubusercontent.com/telkomdev/airflow-aio/main/quick-install.sh' | bash
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
