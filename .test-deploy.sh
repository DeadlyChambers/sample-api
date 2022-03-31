# Using Minikube navigate the namespace and resource tree to hit the deployed api

_environ="$1"
if [ -z "$_environ" ]
    then
        echo -e "Enter the environment you are looking to test, develop or stage" 
        read -p ": "  _environ
    else
        _environ="develop"
fi

echo -e "Running Api System Call - $_environ"

system_port=$(kubectl get services/system-api --namespace ${_environ} -o go-template='{{(index .spec.ports 0).nodePort}}')
echo -e "System Api: $(minikube ip):${system_port}"
curl "http://$(minikube ip):${system_port}/System"

echo -e ""
echo -e "Running Api Data Call - $_environ"

data_port=$(kubectl get services/data-api --namespace ${_environ} -o go-template='{{(index .spec.ports 0).nodePort}}')
if [ -n "${data_port}" ] 
then
    echo -e "Data Api: $(minikube ip):${data_port}"
    curl "http://$(minikube ip):${data_port}/System"
else
    echo "Could not find port"
fi
echo -e ""
