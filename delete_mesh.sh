export mesh_to_delete=$(oci service-mesh mesh list --compartment-id ${mesh_compartment} --all | 
jq '.data.items[] | select(."lifecycle-state" == "ACTIVE") | ."display-name"' | tr -d '"')
export mesh_to_delete_id=$(oci service-mesh mesh list --compartment-id ${mesh_compartment} 
--all | jq '.data.items[] | select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"')
if [ -n "${mesh_to_delete}" ]; then
echo "Deleting namespace ${mesh_to_delete}" 
kubectl delete ns $mesh_to_delete &
sleep 120
kubectl get namespace $mesh_to_delete -o json > out.json                          
sed -i 's/"kubernetes"//g' ./out.json                                                              
kubectl replace --raw "/api/v1/namespaces/${mesh_to_delete}/finalize" -f ./out.json 
sleep 120
oci service-mesh virtual-service-route-table list --all --compartment-id ${compartment_ocid} | jq 
'.data.items[] | select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"' > delete.out
while read line; do
echo "Deleting $line"
oci service-mesh virtual-service-route-table delete --virtual-service-route-table-id  $line --force
done <delete.out
sleep 20
oci service-mesh virtual-deployment list --all --compartment-id ${compartment_ocid} | jq '.data.items[] | 
select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"' > delete.out
while read line; do
echo "Deleting $line"
oci service-mesh virtual-deployment delete --virtual-deployment-id $line --force
done <delete.out
sleep 20
oci service-mesh virtual-service list --all --compartment-id ${compartment_ocid} | jq '.data.items[] | 
select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"' > delete.out
while read line; do
echo "Deleting $line"
oci service-mesh virtual-service delete --virtual-service-id $line --force
done <delete.out
sleep 20
oci service-mesh access-policy list --all --compartment-id ${compartment_ocid} | jq '.data.items[] | 
select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"' > delete.out
while read line; do
echo "Deleting $line"
oci service-mesh access-policy delete --access-policy-id $line --force
done <delete.out
sleep 20
oci service-mesh ingress-gateway-route-table list --all --compartment-id ${compartment_ocid} | jq 
'.data.items[] | select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"' > delete.out
while read line; do
echo "Deleting $line"
oci service-mesh ingress-gateway-route-table delete --ingress-gateway-route-table-id $line --force
done <delete.out
sleep 5
oci service-mesh ingress-gateway list --all --compartment-id ${compartment_ocid} | jq '.data.items[] | 
select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"' > delete.out
while read line; do
echo "Deleting $line"
oci service-mesh ingress-gateway delete --ingress-gateway-id $line --force
done <delete.out
sleep 20
export mesh_to_delete_id=$(oci service-mesh mesh list --compartment-id ${compartment_ocid} | jq 
'.data.items[] | select(."lifecycle-state" == "ACTIVE") | .id' | tr -d '"')
echo "Deleting mesh ${mesh_to_delete}"
oci service-mesh mesh delete --mesh-id $mesh_to_delete_id --force
fi
