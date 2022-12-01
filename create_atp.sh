# Install database via OSOK
# $1 = db name
# $2 = db password
if [ -z "$1" ] || [ -z "$2" ]; then
  exit
fi
sed -i "s/mesh_name/${mesh_name}/g" atp.yaml
sed -i "s/mesh_compartment/${mesh_compartment}/g" atp.yaml
sed -i "s/mesh_dbname/$1/g" atp.yaml
kubectl create namespace ${mesh_name}
kubectl create secret generic admin-secret --from-literal=password=$2 -n ${mesh_name}
kubectl create secret generic wallet-secret --from-literal=walletPassword=$2 -n ${mesh_name}
kubectl create -f atp.yaml
spin='-\|/'
tries=0
atp_status=""
while [ $tries -le 600 ] && [[ $atp_status == '' ]] 
do
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"
  atp_status=$(kubectl get AutonomousDatabases -n ${mesh_name} -o json | jq '.items[] | select(.spec.dbName == "'$1'") | .status' | tr -d '"')
  echo "1> $atp_status"
  if [ "$atp_status" != "" ]; then
    atp_status=$(kubectl get AutonomousDatabases -n ${mesh_name} -o json | jq '.items[] | select(.spec.dbName == "'$1'") | .status' | jq '.status.conditions[].type' | tr -d '"')
    echo "2> $atp_status"
  fi
  tries=$(( $tries + 1 ))
  #sleep 1
done
if [ -z "$atp_status" ]; then
  echo "ATP instance $1 does not exist/could not be created .. Exciting."
else
  echo "ATP instance $1 is active."
fi
