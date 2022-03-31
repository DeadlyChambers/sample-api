# Using Minikube navigate the namespace and resource tree to hit the deployed api

_environ="$1"
if [ -z "$_environ" ]
    then
        echo -e "Enter the environment you are looking to test, develop or stage" 
        read -p ": "  _environ
fi
echo -e "Running Api System Call - $_environ"
cd services || return
system_alb=$(terraform output system_lb_ip)
echo -e "System Api: ${system_alb}"
curl "https://${system_alb}/System"

echo -e ""
echo -e "Running Api Data Call - $_environ"

data_alb=$(terraform output data_lb_ip)

if [ -n "${data_alb}" ] 
then
    echo -e "Data Api: ${data_alb}"
    curl "https://${data_alb}/System"

else
    echo "Could not find data alb"
fi
echo -e ""
cd ... || return;