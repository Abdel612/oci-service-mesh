# ${ca_ocid} - See https://docs.oracle.com/en-us/iaas/Content/service-mesh/ovr-getting-started-osok.htm#service-mesh-getting-install-osok
# $1 = DNS domain name
if [ -z "$1" ]; then
  exit
fi
sed -i "s/mesh_name/${mesh_name}/g" meshify-app.yaml
sed -i "s/mesh_compartment/${mesh_compartment}/g" meshify-app.yaml
sed -i "s/mesh_ca_ocid/${ca_ocid}/g" meshify-app.yaml
sed -i "s/mesh_dns_domain/$1/g" meshify-app.yaml
sed -i "s/mesh_name/${mesh_name}/g" bind-app.yaml
kubectl create -f meshify-app.yaml
kubectl create -f bind-app.yaml
