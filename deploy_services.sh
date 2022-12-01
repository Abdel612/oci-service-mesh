# $1 = OCI registry
if [ -z "$1" ]; then
  exit
fi
sed -i "s/tag/${mesh_version}/g" app.yaml
sed -i "s/mesh_name/${mesh_name}/g" app.yaml
sed -i "s|meshdemo_registry|$1|g" app.yaml
kubectl label namespace $mesh_name servicemesh.oci.oracle.com/sidecar-injection=enabled
kubectl create -f app.yaml