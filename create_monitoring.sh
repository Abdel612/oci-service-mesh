# ${log_object_ocid} = LOG object ocid # See https://docs.oracle.com/en-us/iaas/Content/service-mesh-tutorials/service-mesh-overview/00-overview.htm
oci logging agent-configuration list --all --compartment-id ${mesh_compartment} | jq '.data.items[] | select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"' > delete.out
while read line; do
    echo "$line"
    oci logging agent-configuration delete --config-id $line --force
done <delete.out
sleep 5
sed -i "s/mesh_name/${mesh_name}/g" logconfig.json
sed -i "s/log_object_ocid/${log_object_ocid}/g" logconfig.json
sed -i "s/mesh_name/${mesh_name}/g" grafana.yaml
export groupList=`echo '{"groupList": ["'${logging_dynamicgroup_ocid}'"]}'` oci logging agent-configuration create --compartment-id ${compartment_ocid} --is-enabled true --service-configuration file://logconfig.json --display-name MeshDemoLoggingAgent --description "Custom agent config for ${mesh_name}" --group-association "${groupList}"
#kubectl delete ns monitoring
kubectl create ns monitoring
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml
