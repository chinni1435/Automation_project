s3_bucket="upgrad-manikanta"
my_name="Manikanta"
timestamp=$(date '+%d%m%Y-%H%M%S')

# update the packages
sudo apt update -y

#check if apache2 is installed

if [[ $? == 0  ]] # Exit if previous coammnd fails
then
	if [[ `sudo dpkg-query -l | grep apache2` == *"apache2"* ]] 
	then
		echo "Apache2 is installed"
	else
		echo "Installing Apache2 service....."
		sudo apt install apache2 -y
	fi
else
	exit 1
fi

# Check if the service is running 

if [[ `sudo systemctl status apache2` == *"inactive"* ]]
then
	echo "Apache2 service is not running......, Trying to start the service"
	sudo systemctl start apache2
	if [[ $? != 0 ]]
	then
		exit 1
	fi
fi

#check if service is enabled to start during boot

if [[ `systemctl is-enabled apache2` == *"disabled"* ]]
then
	echo "Enabling service for boot up"
	sudo systemctl enable apache2
fi




#create a tar for the access and error logs

cd /var/log/apache2
tar -cvf $my_name-httpd-logs-$timestamp.tar access.log error.log
mv $my_name-httpd-logs-$timestamp.tar /tmp

# copy the file to s3 bucket
aws s3 cp /tmp/${my_name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${my_name}-httpd-logs-${timestamp}.tar



