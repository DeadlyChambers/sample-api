echo -e "Running Api System Call"

export system_port=$(kubectl get services/system-api -o go-template='{{(index .spec.ports 0).nodePort}}')
curl "http://$(minikube ip):${system_port}/System"

echo -e "\nRunning Api Data Call"

export data_port=$(kubectl get services/data-api -o go-template='{{(index .spec.ports 0).nodePort}}')
curl "http://$(minikube ip):${data_port}/System"
echo -e ""