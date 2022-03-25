# Helm
Helm helps you to orchestrate k8s clusters via a cli, chart repository, and a server running on each cluster that talks to the 
k8s api server. With Helm there are 4 major pieces that you will need to know

**Charts** These are a collection of yaml files that are used to deploy an application. Think of it as a docker image, and the Charts are stored in Helm hub. 

**Config** These are values.yamls that have environment specific configurations that will be paired with the charts for a deploy.

**Release** A chart instance that is released into k8s, that is paired with a config.

**Repository** Where the charts are stored