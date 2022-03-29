# Build the docker images and push to the repository

_app_ver=$1
_app_proj=$2
if [ -z "$_app_ver" ]
    then
        read -p "Enter Version in the form of 6.0.1.8:\n" _app_ver
fi
if [ -z "$_app_proj" ]
    then
        echo "Do you wish to install this program?"
        select _app_proj in "data" "system"; do
            case $_app_proj in
                system ) break;;
                data ) exit;;
            esac
        done
fi

# Build the new images
docker build -t "deadlychambers/soinshane-k8s-$_app_proj:$_app_ver" -t "deadlychambers/soinshane-k8s-$_app_proj:latest" --build-arg APP_VER="$_app_ver" -f "$_app_proj.Dockerfile" . 

# push the images
docker push "deadlychambers/soinshane-k8s-$_app_proj" -a