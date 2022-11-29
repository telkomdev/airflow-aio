#!/usr/bin/env bash

if [ $(id -u) != '0' ]; then
  echo "This script must be run as root"
  exit 1
fi

install_python() {
  apt-get update -y \
    && apt-get install --no-install-recommends -y \
      python3 \
      python3-pip
}

install_prerequisites() {
  apt-get install --no-install-recommends -y \
      libpython3-dev \
      libpq-dev \
      gcc \
      screen \
      nano \
      tzdata \
      nginx \
      mysql-server \
      libmysqlclient-dev
}

install_airflow() {
  AIRFLOW_VERSION=2.4.3
  PYTHON_VERSION="$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
  CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
  pip3 install "apache-airflow[async,postgres,google]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
}

install_instantclient() {
  INSTANT_CLIENT_VERSION="21.7.0"
  ORACLE_BASE="/opt/oracle/instantclient"
  ORACLE_HOME="/opt/oracle/instantclient"
  TNS_ADMIN="/opt/oracle/instantclient"
  LD_LIBRARY_PATH="/opt/oracle/instantclient:${LD_LIBRARY_PATH}"
  PATH="/opt/oracle/instantclient:${PATH}"
  apt-get update -y
  apt-get install -y --no-install-recommends \
      libaio1
  apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      unzip
  curl -H 'Cache-Control: no-cache' -Lo instantclient.zip "https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basiclite-linux.x64-${INSTANT_CLIENT_VERSION}.0.0dbru.zip"
  sha256_oci="8a745ad7f4290ff8f7bd1d9436f6afdf07644e390b5d6acc3dc50978687795cb"
  echo "${sha256_oci}  instantclient.zip" | sha256sum -c - || exit 1
  unzip instantclient.zip
  rm -f instantclient.zip
  mkdir -p ${ORACLE_BASE}
  mv instantclient_*/* ${ORACLE_BASE}/
  rm -rf instantclient_*
  echo "${ORACLE_BASE}" > /etc/ld.so.conf.d/oracle-instantclient.conf
  ldconfig
}

configure_airflow() {
  # configure local time
  ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

  # init airflow workdir
  airflow version

  # change timezone
  sed -i 's/default_ui_timezone = UTC/default_ui_timezone = Asia\/Jakarta/g' /root/airflow/airflow.cfg
  # change executor to LocalExecutor
  sed -i 's/executor = SequentialExecutor/executor = LocalExecutor/g' /root/airflow/airflow.cfg
  # update DB engine to mysql
  sed -i 's/sql_alchemy_conn = sqlite:\/\/\/\/root\/airflow\/airflow.db/sql_alchemy_conn = mysql+mysqldb:\/\/airflow:AirflowDBPass@localhost:3306\/airflow/g' /root/airflow/airflow.cfg
  # initialize Airflow DB
  airflow db init
  # add Airflow admin user
  airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin
}

start_airflow() {
  screen -AmdS airflow-webserver airflow webserver -p 8080
  screen -AmdS airflow-scheduler airflow scheduler
}

install_providers() {
  pip3 install \
      cx-oracle \
      mysqlclient
}

configure_mysql() {
  mysql -u root -e "CREATE USER 'airflow'@'localhost' IDENTIFIED by 'AirflowDBPass';"
  mysql -u root -e "CREATE DATABASE airflow;"
  mysql -u root -e "GRANT ALL PRIVILEGES ON airflow.* TO 'airflow'@'localhost' WITH GRANT OPTION;"
}

configure_nginx() {
  systemctl stop nginx
  curl -H 'Cache-Control: no-cache' -sko /etc/nginx/sites-available/default https://raw.githubusercontent.com/telkomdev/airflow-aio/main/nginx/default
  systemctl start nginx
  systemctl enable nginx
}

post_install_airflow() {
  echo "Airflow installed successfully!"
}

install_python \
  && install_prerequisites \
  && install_airflow \
  && install_instantclient \
  && install_providers \
  && configure_mysql \
  && configure_airflow \
  && start_airflow \
  && configure_nginx \
  && post_install_airflow

