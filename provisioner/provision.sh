#!/bin/bash

#Versão de testes

# Verificar a arquitetura
architecture=$(uname -m)

if [ $architecture == "x86_64" ]; then
    mariadb_package="mariadb-server"
elif [ $architecture == "aarch64" ]; then
    mariadb_package="mariadb-server-10.5"
else
    echo "Arquitetura não suportada."
    exit 1
fi

# Verificar o tipo de distribuição Linux
if [ -f /etc/os-release ]; then
    source /etc/os-release
    distribution=$ID
elif [ -f /etc/redhat-release ]; then
    distribution=$(cat /etc/redhat-release | cut -d ' ' -f 1)
else
    echo "Não foi possível identificar a distribuição Linux."
    exit 1
fi

# Instalar o MariaDB de acordo com a distribuição e arquitetura
if [ $distribution == "debian" ] || [ $distribution == "ubuntu" ]; then
    apt-get update
    apt-get install -y $mariadb_package
elif [ $distribution == "centos" ] || [ $distribution == "rhel" ]; then
    yum update
    yum install -y $mariadb_package
else
    echo "Distribuição Linux não suportada."
    exit 1
fi

# Configurar a conexão para todos os hosts
echo -e "[mysqld]\nbind-address=0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
service mysql restart

# Criar um usuário com permissão total
mysql -e "CREATE USER 'novousuario'@'%' IDENTIFIED BY 'senhanovousuario'; GRANT ALL PRIVILEGES ON *.* TO 'novousuario'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

echo "A instalação e configuração do MariaDB foram concluídas com sucesso."
echo "Usuário: novousuario"
echo "Senha: senhanovousuario"
