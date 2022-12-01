# $1 = OCI registry
# $1 = docker username
# $2 = docker password (api key)
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  exit
fi
sed -i "s/tag/${mesh_version}/g" app.yaml
sed -i "s/mesh_name/${mesh_name}/g" app.yaml
sed -i "s|meshdemo_registry|$1|g" app.yaml
kubectl label namespace $mesh_name servicemesh.oci.oracle.com/sidecar-injection=enabled
kubectl create secret docker-registry ocirsecret -n $mesh_name --docker-server $1 --docker-username $2 --docker-password $3
kubectl create -f app.yaml