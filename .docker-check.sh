# Not really using this, it was added when I was using docker hub
# Just output the tags for each container
echo -e "System Tags\n"
wget -q https://registry.hub.docker.com/v1/repositories/deadlychambers/soinshane-k8s-system/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'
echo -e ""
echo -e "Data Tags\n"
wget -q https://registry.hub.docker.com/v1/repositories/deadlychambers/soinshane-k8s-data/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'