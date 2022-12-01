# $1 = db name
# $2 = db password
# $3 = OCI registry
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  exit
fi
# BUILD PRICE v1
mkdir -p ./price/Wallet
kubectl get secret wallet -n ${mesh_name} -o jsonpath='{.data}' | jq '."tnsnames.ora"' | tr -d '"' | 
base64 --decode > ./price/Wallet/tnsnames.ora
kubectl get secret wallet -n ${mesh_name} -o jsonpath='{.data}' | jq '."sqlnet.ora"' | tr -d '"' | 
base64 --decode > ./price/Wallet/sqlnet.ora
kubectl get secret wallet -n ${mesh_name} -o jsonpath='{.data}' | jq '."cwallet.sso"' | tr -d '"' | 
base64 --decode > ./price/Wallet/cwallet.sso
sed -i "s|"?/network/admin"|"./Wallet"|g" ./price/Wallet/sqlnet.ora
cd ./price/Wallet
zip ./Wallet.zip *
cd ../..
mkdir ./Wallet
mv ./price/Wallet/Wallet.zip ./Wallet/.
cd ./price/
sed -i "s/meshdemo_dbname/$1/g" ./price.js
sed -i "s/atp_pwd/$2/g" ./price.js
sed -i "s/admin_pwd/$2/g" ./price.js
wget ${instant_client} -q
docker build -t $3/meshdemo-pricesvc:v1-${mesh_name} .
docker push $3/meshdemo-pricesvc:v1-${mesh_name}
cd ..
# BUILD HOME v1 - STATIC
cd ./home/
cp ./html/pricing/index_static.html ./html/pricing/index.html
docker build -t $3/meshdemo-homesvc:v1-${mesh_name} .
docker push $3/meshdemo-homesvc:v1-${mesh_name}
# BUILD HOME v2 - DYNAMIC
export admin_link=admin.${dns_domain}
sed -i "s|admin_link|${admin_link}|g" ./html/pricing/index_dynamic.html
cp ./html/pricing/index_dynamic.html ./html/pricing/index.html
docker build -t $3/meshdemo-homesvc:v2-${mesh_name} .
docker push $3/meshdemo-homesvc:v2-${mesh_name}
