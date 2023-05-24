# #!/bin/bash

# # Verificar a arquitetura
# architecture=$(uname -m)

# if [ $architecture == "x86_64" ]; then
#     mariadb_package="mariadb-server"
# elif [ $architecture == "aarch64" ]; then
#     mariadb_package="mariadb-server-10.5"
# else
#     echo "Arquitetura não suportada."
#     exit 1
# fi

# sllep 3
# # Verificar o tipo de distribuição Linux e gerenciador de pacotes
# if [ -f /etc/os-release ]; then
#     source /etc/os-release
#     distribution=$ID
#     package_manager=$(command -v apt-get || command -v dnf || command -v yum)
# elif [ -f /etc/redhat-release ]; then
#     distribution=$(cat /etc/redhat-release | cut -d ' ' -f 1)
#     package_manager=$(command -v yum || command -v dnf)
# else
#     echo "Não foi possível identificar a distribuição Linux."
#     exit 1
# fi

# sleep 3
# # Instalar o MariaDB de acordo com a distribuição, arquitetura e gerenciador de pacotes
# if [ $distribution == "debian" ] || [ $distribution == "ubuntu" ]; then
#     $package_manager update
#     sudo $package_manager install -y $mariadb_package
#     sleep 20
# elif [ $distribution == "centos" ] || [ $distribution == "rhel" ]; then
#     $package_manager update
#     sudo $package_manager install -y $mariadb_package
#     sleep 20
# else
#     echo "Distribuição Linux não suportada."
#     exit 1
# fi

# # Configurar a conexão para todos os hosts
# echo -e "[mysqld]\nbind-address=0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
# service mysql restart

# # Criar um usuário com permissão total
# mysql -e "CREATE USER 'sog'@'%' IDENTIFIED BY 'sog'; GRANT ALL PRIVILEGES ON *.* TO 'sog'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# echo "A instalação e configuração do MariaDB foram concluídas com sucesso."
# echo "Usuário: novousuario"
# echo "Senha: senhanovousuario"

#=============================================================#

#!/bin/bash

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
sleep 3

# Verificar o tipo de distribuição Linux e gerenciador de pacotes
if [ -f /etc/os-release ]; then
    source /etc/os-release
    distribution=$ID
    package_manager=$(command -v apt-get || command -v dnf || command -v yum)
elif [ -f /etc/redhat-release ]; then
    distribution=$(cat /etc/redhat-release | cut -d ' ' -f 1)
    package_manager=$(command -v yum || command -v dnf)
else
    echo "Não foi possível identificar a distribuição Linux."
    exit 1
fi
sleep 3

# Instalar o MariaDB de acordo com a distribuição, arquitetura e gerenciador de pacotes
if [ $distribution == "debian" ] || [ $distribution == "ubuntu" ]; then
    $package_manager update
    sudo $package_manager install -y $mariadb_package > /dev/null 2>&1
    sleep 60

    # Configurar a conexão para todos os hosts no arquivo de configuração
    echo -e "[mysqld]\nbind-address=0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf

    # Reiniciar o serviço do MariaDB
    sudo service mysql restart || systemctl restart mariadb
    sleep 15
elif [ $distribution == "centos" ] || [ $distribution == "rhel" ]; then
    $package_manager update
    sudo $package_manager install -y $mariadb_package > /dev/null 2>&1
    sleep 60
    # Configurar a conexão para todos os hosts no arquivo de configuração
    echo -e "[mysqld]\nbind-address=0.0.0.0" >> /etc/my.cnf.d/server.cnf

    # Reiniciar o serviço do MariaDB
    sudo systemctl restart mariadb || sudo service mariadb restart
    sleep 15
else
    echo "Distribuição Linux não suportada."
    exit 1
fi

DATABASE='sog'
username='sog'
IP=$(hostname -I | awk '{print $2}')
password=$(date +%s | sha256sum | base64 | head -c 16)
echo "Senha gerada para o usuário '$username': $password"
sleep 3

# Criar um usuário com permissão total
mysql -e "CREATE USER '$username'@'%' IDENTIFIED BY '$password'; GRANT ALL PRIVILEGES ON *.* TO '$username'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES; CREATE DATABASE $DATABASE;"

echo "A instalação e configuração do MariaDB foram concluídas com sucesso."
echo "Usuário: $username"
echo "Senha: $password"
echo "IP VM: $IP"

#Salva a senha do DB na home do user vagrant
echo "$password" >> /home/vagrant/mariadb_pass.txt

echo -e "Para conectar-se ao DB basta seguir os passos:\n"
echo -e "01 - possuir um SGBD, por exemplo, HEID ou DBEAVER\n"
echo -e "02 - Criar uma nova conexão para o MariaDB\n"
echo -e "03 - Utilizar o database: $DATABASE junto com as credenciais fornecidas acima\n"
echo -e "04 - O host a ser utilizado pode ser o localhost ou $IP"

