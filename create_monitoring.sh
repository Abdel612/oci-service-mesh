# ${log_object_ocid} = LOG object ocid # See https://docs.oracle.com/en-us/iaas/Content/service-mesh-tutorials/service-mesh-overview/00-overview.htm
# ${logging_dynamicgroup_ocid}
sed -i "s/mesh_name/${mesh_name}/g" logconfig.json
sed -i "s/log_object_ocid/${log_object_ocid}/g" logconfig.json
sed -i "s/mesh_name/${mesh_name}/g" grafana.yaml
groupList=`echo '{"groupList": ["'${logging_dynamicgroup_ocid}'"]}'`
oci logging agent-configuration create --compartment-id ${mesh_compartment} --is-enabled true --service-configuration file://logconfig.json --display-name ${mesh_name}MeshLoggingAgent --description "Custom agent config for ${mesh_name}" --group-association "${groupList}"
kubectl create ns monitoring
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml
