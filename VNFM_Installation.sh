#!/bin/bash

WarFilevnfmanager="$CATALINA_HOME/webapps/vnf-manager.war"
WarFilevnfdm="$CATALINA_HOME/webapps/vnfdm.war"
WarFilevnflcm="$CATALINA_HOME/webapps/vnflcm.war"
WarFilecnpl="$CATALINA_HOME/webapps/cnpl.war"
WarFilevimpl="$CATALINA_HOME/webapps/vimpl.war"
WarFilevnfmm="$CATALINA_HOME/webapps/vnfmm.war"
WarFilevnfpm="$CATALINA_HOME/webapps/vnfpm.war"
WarFilevnfsmm="$CATALINA_HOME/webapps/vnfsmm.war"
WarFileoauthweb="$CATALINA_HOME/webapps/oauth-web.war"
WarFilevnfcdpl="$CATALINA_HOME/webapps/cdpl.war"
clear
echo "VNFM INSTALLATION BEGINS"
echo

sudo kill -9 $(ps aux | grep '[c]atalina' | awk '{print $2}')
#$CATALINA_HOME/bin/catalina.sh stop > /dev/null 2>&1 || true
echo "Stopping CATALINA"
echo
sleep 3

rm -rf $CATALINA_HOME/webapps/cnpl $CATALINA_HOME/webapps/oauth-web $CATALINA_HOME/webapps/vimpl $CATALINA_HOME/webapps/vnfdm $CATALINA_HOME/webapps/vnflcm $CATALINA_HOME/webapps/vnf-manager $CATALINA_HOME/webapps/vnfmm $CATALINA_HOME/webapps/vnfpm $CATALINA_HOME/webapps/vnfsmm $CATALINA_HOME/webapps/cdpl

if [ -f "$WarFilevnfmanager" ] && [ -f "$WarFilevnfdm" ] && [ -f "$WarFilevnflcm" ] && [ -f  "$WarFilecnpl" ] && [ -f "$WarFilevimpl" ] && [ -f "$WarFilevnfmm" ] && [ -f "$WarFilevnfpm" ] && [ -f "$WarFilevnfsmm" ] && [ -f "$WarFileoauthweb" ] && [ -f "$WarFilevnfcdpl" ]
then
        echo "All Required Files are in place in $CATALINA_HOME/webapps/ Folder"
else
	echo "PLEASE CHECK IF ALL REQUIRED FILES FOR INSTALLATION ARE PLACED IN $CATALINA_HOME/webapps/ Folder
Copy all "war, jar, dbcreation.sql, config.properties" files to $CATALINA_HOME/webapps/ folder"
	echo
	exit 1
fi	

mysql -uroot -proot < $CATALINA_HOME/webapps/dbcreation.sql > /dev/null 2>&1 || true
echo
echo "MARIA Database is created successfully"

cqlsh localhost -e "DROP KEYSPACE mykeyspace;" > /dev/null 2>&1 || true
cqlsh localhost -e "create keyspace mykeyspace with replication = {'class':'SimpleStrategy', 'replication_factor':1};" > /dev/null 2>&1 || true
echo
echo "mykeyspace for CASSANDRA is created successfully"

cqlsh localhost -e "DROP KEYSPACE smm;" > /dev/null 2>&1 || true
cqlsh localhost -e "create keyspace smm with replication = {'class':'SimpleStrategy', 'replication_factor':1};" > /dev/null 2>&1 || true
echo
echo "cassandraSmmKeyspace smm created successfully"


if [ -f "$CATALINA_HOME/config.properties" ]; then
	rm $CATALINA_HOME/config.properties
fi

cp $CATALINA_HOME/webapps/config.properties $CATALINA_HOME


if [ -f "$CATALINA_HOME/config.properties" ]; then
	echo
	echo -n "Config.properties file successfully placed"
	echo
else
	echo -n "Config.properties file could not be placed to $CATALINA_HOME"
	echo
fi

if [ -d "$CATALINA_HOME/cloudPlugin" ]; then

	rm -rf $CATALINA_HOME/cloudPlugin
fi

mkdir $CATALINA_HOME/cloudPlugin

cp $CATALINA_HOME/webapps/*.jar $CATALINA_HOME/cloudPlugin

if [ -f "$CATALINA_HOME/cloudPlugin/openstack_PL.jar" ] && [ -f "$CATALINA_HOME/cloudPlugin/vmware_PL.jar" ]
then
	echo
	echo -n "Plugins are successfully placed"
	echo
	echo
else
	echo -n "Plugins couldn't be placed to pluginPath"
	echo
	echo
fi

echo "#####################################################################################"
echo

while [ "$public_ip" == "" ]; do
	echo -n  "Enter Public IP of Cloud Instance Where You would want to install VNFM: "
	read  public_ip
	echo
done

while [ "$confd_ip" == "" ]; do
	echo -n  "Enter IP of CONFD server: "
	read  confd_ip
	echo
done

while [ "$cms_ip" == "" ]; do
	echo -n  "Enter IP of CMS: "
	read  cms_ip
	echo
done


echo
echo "		######################################################"
    	
echo "		Public IP of Cloud Instance is:"$public_ip
echo "		IP of CONFD is:"$confd_ip    
echo "		IP of CMS is:"$cms_ip 			    
echo "		######################################################" 	     	

sed -i -e "/^cnplIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^vnfdmIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^vimplIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^vnfmmIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^vnfpmIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^vnfsmmIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^kafkaIp/ s/172.19.63.14/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^cassandraIp/ s/172.19.63.14/localhost/" $CATALINA_HOME/config.properties
sed -i -e "/^vnflcmIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^isHeat/ s/false/true/" $CATALINA_HOME/config.properties
sed -i -e "/^graphiteIp/ s/172.19.53.111/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^graphiteURL/ s/172.19.63.19/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^vnfcdplIp/ s/localhost/$public_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^ConfdIpaddress/ s/10.203.138.165/$confd_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^vnfcmsIp/ s/localhost/$cms_ip/" $CATALINA_HOME/config.properties
sed -i -e "/^ConfdSupported/ s/true/false/" $CATALINA_HOME/config.properties

sed -i -e "/^pluginPath/ s|\\\\|_|g" $CATALINA_HOME/config.properties
sed -i -e "/^pluginPath/ s|D:__VNFM__di_vnfm__vim-plugin__vimpl_PL__target|$CATALINA_HOME/cloudPlugin|" $CATALINA_HOME/config.properties
sed -i -e "/^pluginPath/ s|/|//|g" $CATALINA_HOME/config.properties



if [ -f "$WarFilevnfmanager" ] && [ -f "$WarFilevnfdm" ] && [ -f "$WarFilevnflcm" ] && [ -f  "$WarFilecnpl" ] && [ -f "$WarFilevimpl" ] && [ -f "$WarFilevnfmm" ] && [ -f "$WarFilevnfpm" ] && [ -f "$WarFilevnfsmm" ] && [ -f "$WarFileoauthweb" ] && [ -f "$WarFilevnfcdpl" ]
then
	echo				
	echo "<<<All war files are in place>>>"
	$CATALINA_HOME/bin/catalina.sh start > /dev/null 2>&1 || true
	echo "<<<<<<<<Starting CALALINA>>>>>>>"
	echo 
	echo -n "<<<<<<<<<<<<<Please wait for sometime until wars get deployed.>>>>>>>>>>>
     <<<This can be verified by checking logfile logs/catalina.out>>>
    		<<<(look for server startup in ***** ms).>>>"
	$CATALINA_HOME/bin/catalina.sh start > /dev/null 2>&1 || true	
	echo
	echo
	seconds=180; date1=$((`date +%s` + $seconds)); 
	while [ "$date1" -ge `date +%s` ]; do 
  	echo -ne "			$(date -u --date @$(($date1 - `date +%s` )) +%H:%M:%S)\r"; 
	done	
	

#	rm -rf $CATALINA_HOME/webapps/cnpl $CATALINA_HOME/webapps/oauth-web $CATALINA_HOME/webapps/vimpl $CATALINA_HOME/webapps/vnfdm $CATALINA_HOME/webapps/vnflcm $CATALINA_HOME/webapps/vnf-manager $CATALINA_HOME/webapps/vnfmm $CATALINA_HOME/webapps/vnfpm $CATALINA_HOME/webapps/vnfsmm
	
	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/cnpl/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/cnpl/WEB-INF/classes/application.properties

	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vimpl/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vimpl/WEB-INF/classes/application.properties

	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfdm/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfdm/WEB-INF/classes/application.properties
	
	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnflcm/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnflcm/WEB-INF/classes/application.properties

	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnf-manager/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnf-manager/WEB-INF/classes/application.properties

	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfmm/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfmm/WEB-INF/classes/application.properties

	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfpm/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfpm/WEB-INF/classes/application.properties

	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfsmm/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/vnfsmm/WEB-INF/classes/application.properties
	
	sed -i -e "/^oauth.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/cdpl/WEB-INF/classes/application.properties
	sed -i -e "/^module.host/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/cdpl/WEB-INF/classes/application.properties


	sed -i -e "/^INSERT/ s/localhost/$public_ip/" $CATALINA_HOME/webapps/oauth-web/WEB-INF/classes/import.sql


##Confd related config####

	sed -i -e "32s/10.203.138.168/$confd_ip/"  $CATALINA_HOME/webapps/cdpl/WEB-INF/classes/confd.conf
	sed -i.bak -e '30d;35d' $CATALINA_HOME/webapps/cdpl/WEB-INF/classes/confd.conf
	sleep 3

##########################
	sudo kill -9 $(ps aux | grep '[c]atalina' | awk '{print $2}')
	sleep 3
	$CATALINA_HOME/bin/catalina.sh start
	sleep 3
	
else
	echo "Some war files are missing in webapps folder."
fi
echo
echo
echo "#################################################
#########You are good to get on##################
#####VNFM Installation Is Successfully Done######
#################################################"
