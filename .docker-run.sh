# Currently not setup, but should be easy enough to copy everything
# from the readme.md to just have it swap out version, and app

_app_ver=$1
_app_proj=$2
_repo=$3
if [ -z "$_app_ver" ]    
then
        echo -e "Enter Version in the form of 6.0.1.8" 
        read -p ": "  _app_ver
fi
if [ -z "$_repo" ]    
then
        _repo="dockerhub"
fi

if [ "$_repo" == "dockerhub" ]   
then
     _repo="deadlychambers/soinshane-k8s"
fi
if [ "$_repo" == "sample-api" ]    
then
        echo "$_repo"
else
        aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/w7a3q5r
        _repo="public.ecr.aws/w7a3q5r4/soinshane/k8s"
fi

# Build the new images
docker build --target final -t "$_repo-$_app_proj:$_app_ver" -t "$_repo-$_app_proj:latest" --build-arg APP_VER="$_app_ver" -f "$_app_proj.Dockerfile" . 
# push the images
docker push "$_repo-$_app_proj" -a

