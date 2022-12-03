# $1 = home/admin
# $2 = DNS domain name
# $3 = region
# $4 = IP addr
# ${dns_compartment}  OPTIONAL
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  exit
fi
compartment=${mesh_compartment}
if [ -n "${dns_compartment}" ]; then
  compartment=${dns_compartment}
fi
name=$1.$2
zone=$(oci dns record domain get --domain ${name} --zone-name-or-id $2 -c 
${compartment} --region $3 | jq '.data.items[] | select(."domain" == "'${name}'") | .domain ' | tr -d '"')
echo "zone: $zone"
echo "name: $name"
if [ "$zone" != "${name}" ]; then
 oci dns zone create -c ${compartment} --name $2 --zone-type 'PRIMARY' --region $3
fi
export items=`echo '[{"domain": "'${name}'","is-protected": false,"rdata": "'$4'","rrset-version": "2","rtype": "A","ttl": 1800 }]'`
echo $items
oci dns record domain update --domain ${name} --zone-name-or-id ${dns_domain} -c ${compartment} --items="${items}" --region $3 --force
