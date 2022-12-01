sed -i "s/mesh_name/${mesh_name}/g" app.yaml
sed -i "s|meshdemo_registry|${ocir}|g" app.yaml
kubectl label namespace $mesh_name servicemesh.oci.oracle.com/sidecar-injection=enabled
kubectl create -f app.yaml