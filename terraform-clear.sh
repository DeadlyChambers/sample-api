
# cp terraform-clear.sh ~/profile.d/
function terraform-clear-state(){
     if [ "$1" == "*help" ] || [ "$1" == "*-h" ]
          then
          echo -e "${Green}The command will remove all tfstate files from directory forcefully${White}"
          return 0;
      fi
      echo -e "${BCyan}**Custom Command**${Yellow}"
      set -x
      rm -rf .terraform/
      rm -rf .terraform.lock.hcl
      rm -rf terraform.tfstate.d
      rm -rf terraform.tfstate
      rm -rf terraform.tfstate.backup
      set +x
      echo -e "${BGreen}removed all terraform state files${White}"
      return 0;
}
export -f terraform-clear-state