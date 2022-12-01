# Install database via OSOK
# $1 = db name
# $2 = db password
sed -i "s/mesh_name/${mesh_name}/g" atp.yaml
sed -i "s/mesh_compartment/${compartment_ocid}/g" atp.yaml
sed -i "s/meshdemo_dbname/$1/g" atp.yaml
kubectl create namespace ${mesh_name}
kubectl create secret generic admin-secret --from-literal=password=$2 -n ${mesh_name}
kubectl create secret generic wallet-secret --from-literal=walletPassword=$2 -n ${mesh_name}
kubectl create -f atp.yaml
spin='-\|/'
tries=0
export atp_status=''
while [ $tries -le 30 ] && [[ $atp_status != 'Active' ]] 
do
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}
  atp_status=$(./kubectl get AutonomousDatabases -n ${meshdemo_version} -o json | jq 
'.items[]'.status.status.conditions[].type)
  if [ "$atp_status" != "" ]; then
   atp_status=$(./kubectl get AutonomousDatabases -n ${meshdemo_version} -o json | jq 
'.items[].status.status.conditions[] | select(."type" == "Active") | .type' | tr -d '"')
  fi
  tries=$(( $tries + 1 ))
  #sleep 1
done
if [ -z "$atp_status" ]; then
  echo "ATP instance $1 does not exist/could not be created .. "
else
  echo "ATP instance $1 running."
fi
