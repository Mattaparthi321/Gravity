#Check the nginx service is running or not.
status=$(service nginx status)
echo $status
#Condition to start the service.

if [ $? -eq 0 ]; then
    echo "Nginx Is Running"
else
    echo "Nginx Is Not running"
    service nginx start
fi
