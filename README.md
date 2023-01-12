# Create App
This should create a loadbalancer, ec2, security groups, egress, auto scaling group, ami, lt, and anything else to create a free standing .net app

## Step One
Create the Golden Image, and create a Launch Template to utilize this image

# Setup tooling for terraform
Install the recommended plugins for vs code in this project. Restart vs code.
```
#Had issues installing this, and using, but could be a good
#snippet lib
#nvm install lts/dubnium
#nvm use lts/dubnium
#npm install --dev
#npm run build:snippets

#setup some terraform, and terraform-ls configuration for provider caching
mkdir ~/.logs
mkdir ~/.terraform.d/plugin-cache -p
touch ~/.terraformrc
echo "
plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true
provider_installation {
  direct {
    include = ["registry.terraform.io/hashicorp/*"]
  }
}
" > ~/.terraformrc
echo "
export TF_CLI_CONFIG_FILE=$HOME/.terraformrc
export TF_LOG_PATH=~/.logs/tfcli.logs
" >> ~/.profile


_version=0.27.0
#install tf language server
curl -LO "https://github.com/hashicorp/terraform-ls/releases/download/v${_version}/terraform-ls_${_version}_linux_amd64.zip"
unzip "terraform-ls_${_version}_linux_amd64.zip"
rm "terraform-ls_${_version}_linux_amd64.zip"
sudo mv terraform-ls /usr/bin

_version=0.0.12
url -LO "https://github.com/juliosueiras/terraform-lsp/releases/download/v${_version}/terraform-lsp_${_version}_linux_amd64.tar.gz"
tar -xvf "terraform-lsp_${_version}_linux_amd64.tar.gz"
rm "terraform-lsp_${_version}_linux_amd64.tar.gz"
sudo mv terraform-lsp /usr/bin

```
Then restart and you should have everything configured for the workspace via .vscode/settings.json