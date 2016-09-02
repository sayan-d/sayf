#!/bin/sh
#By Sayan Das
#This script can be used to install JAVA, MySQL, Jmeter ServerAgent & Apache in Centos 6.x or Amazon Linux 2016.x

#Vars
BUILD_VERSION="b03"
JAVA_VERSION="8u77"
MYSQL_MAJOR="5.6"
MYSQL_VERSION="5.6.30-1.linux_glibc2.5"

#Option
installOption=$1



javaInstall() {
wget --quiet --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm
rpm -ivh /tmp/jdk-8-linux-x64.rpm
alternatives --install /usr/bin/java java /usr/java/latest/bin/java 200000 && \
alternatives --install /usr/bin/jar jar /usr/java/latest/bin/jar 200000 && \
alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000 && \
alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000

wget --quiet --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip -O /tmp/jce_policy-8.zip && \
unzip /tmp/jce_policy-8.zip -d /tmp/ && \
cd /tmp/UnlimitedJCEPolicyJDK8/ && \
cp -pfd /tmp/UnlimitedJCEPolicyJDK8/*.jar /usr/java/default/jre/lib/security/
}

mysqlInstall() {
echo -e "Removing any mysql-libs package if present by default"
rpm -e mysql-libs-* --nodeps

echo -e "Downloading MySQL 5.6.x and installing .."
wget --no-check-certificate --no-cookies "http://dev.mysql.com/get/Downloads/MySQL-$MYSQL_MAJOR/MySQL-$MYSQL_VERSION.x86_64.rpm-bundle.tar"  -O /tmp/MySQL-$MYSQL_MAJOR-bundle.tar


yum -y install perl-Data-Dumper
tar -xvf /tmp/MySQL-$MYSQL_MAJOR-bundle.tar --directory /tmp/

yum -y --nogpgcheck install /tmp/MySQL-client-$MYSQL_VERSION.x86_64.rpm && \
yum -y --nogpgcheck install /tmp/MySQL-devel-$MYSQL_VERSION.x86_64.rpm && \
yum -y --nogpgcheck install /tmp/MySQL-shared-$MYSQL_VERSION.x86_64.rpm && \
yum -y --nogpgcheck install /tmp/MySQL-server-$MYSQL_VERSION.x86_64.rpm

mkdir -p /var/run/mysqld
chown mysql: /var/run/mysqld
wget https://raw.githubusercontent.com/sayan-d/sayf/master/sample-my.cnf -O /etc/my.cnf

# cleanup
rm -f /tmp/MySQL-$MYSQL_MAJOR-bundle.tar && \
rm -f /tmp/MySQL-client-$MYSQL_VERSION.x86_64.rpm && \
rm -f /tmp/MySQL-devel-$MYSQL_VERSION.x86_64.rpm && \
rm -f /tmp/MySQL-shared-$MYSQL_VERSION.x86_64.rpm && \
rm -f /tmp/MySQL-server-$MYSQL_VERSION.x86_64.rpm && \
rm -f /tmp/MySQL-*.rpm

/etc/init.d/mysql start
echo -e "Run mysql_secure_installation .."
}

jmeterServerAgentInstall() {
wget http://jmeter-plugins.org/downloads/file/ServerAgent-2.2.1.zip -O /tmp/ServerAgent-2.2.1.zip
unzip /tmp/ServerAgent-2.2.1.zip -d /usr/local/jmeterServerAgent/

#To start jmeter ServerAgent
#/usr/local/jmeterServerAgent/startAgent.sh
}

apache24Install() {
yum -y install httpd24 httpd24-tools

rpm -qa | grep httpd24 > /dev/null
if [ $? -eq 0 ];then
 echo -e "Installed httpd24 successfully"
else
 echo -e "Intallation failed, exiting"
 exit 1
fi

echo -e "Comment out prefork line"
sed -i '/ mpm_prefork_module /s/^/#/' /etc/httpd/conf.modules.d/00-mpm.conf

echo -e "Uncomment event mpm line"
sed -i '/^#.* mpm_event_module /s/^#//' /etc/httpd/conf.modules.d/00-mpm.conf

/etc/init.d/httpd restart

echo -e "Checking current mpm"
httpd -V | grep "Server MPM"
}


case $installOption in
java)
  echo -e "Installer will install Java $JAVA_VERSION .."
  javaInstall
  ;;
mysql)
  echo -e "Installer will install MySQL $MYSQL_MAJOR .."
  mysqlInstall
  ;;
jmeterServerAgent)
  echo -e "Installer will install jmeter Server Agent 2.2.1"
  jmeterServerAgentInstall
  ;;
httpd)
  echo -e "Installer will install Apache version 2.4.18+ with Event Mpm"
  apache24Install
  ;;
zeeNODE)
  echo -e "Installer will install mysql, jmeterServerAgent"
  mysqlInstall
  jmeterServerAgentInstall
  ;;
zeeLB)
  echo -e "Installer will install Apache, jmeterServerAgent"
  apache24Install
  jmeterServerAgentInstall
  ;;
--help|-h)
  echo -e "Choose any of the following options : ./scriptname.sh java / mysql / jmeterServerAgent / httpd / zeeNODE / zeeLB"
  ;;
esac
