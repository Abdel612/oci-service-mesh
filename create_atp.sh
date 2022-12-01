# Install database via OSOK
# $1 = db name
# $2 = db password
sed -i "s/mesh_name/${mesh_name}/g" atp.yaml
sed -i "s/mesh_compartment/${mesh_compartment}/g" atp.yaml
sed -i "s/mesh_dbname/$1/g" atp.yaml
kubectl create namespace ${mesh_name}
kubectl create secret generic admin-secret --from-literal=password=$2 -n ${mesh_name}
kubectl create secret generic wallet-secret --from-literal=walletPassword=$2 -n ${mesh_name}
kubectl create -f atp.yaml
spin='-\|/'
tries=0
atp_status=''
# Let's wait for a minute ATP to start up ..
while [ $tries -le 60 ]
do
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"
  tries=$(( $tries + 1 ))
  sleep 1
done
atp_status=$(kubectl get AutonomousDatabases -n ${mesh_name} -o json | jq '.items[].status.status.conditions[].type' | tr -d '"')
echo $atp_status
if [ "$atp_status" != "Provisioning" ] && [[ $atp_status != 'Active' ]] ; then
  echo "ATP instance $1 does not exist/could not be created .. "
  exit
fi
# .. then start polling for status if it is found
tries=0
atp_status=''
while [ $tries -le 300 ] && [[ $atp_status != 'Active' ]] 
do
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"
  atp_status=$(kubectl get AutonomousDatabases -n ${mesh_name} -o json | jq '.items[].status.status.conditions[] | select(."type" == "Active") | .type' | tr -d '"')
  tries=$(( $tries + 1 ))
  #sleep 1
  echo $atp_status
done
if [ -z "$atp_status" ]; then
  echo "ATP instance $1 does not exist/could not be created .. "
else
  echo "ATP instance $1 running."
fi
