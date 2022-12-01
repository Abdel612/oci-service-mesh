# $1 = db name
# $2 = db password
# $3 = OCI registry
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  exit
fi
if [ ! -f "instantclient-basic-linux.x64-21.7.0.0.0dbru.zip" ]; then
  "Download instantclient-basic-linux.x64-21.7.0.0.0dbru.zip from OTN with wget at https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip first"
  exit
else
    mv instantclient-basic-linux.x64-21.7.0.0.0dbru.zip ./price/
fi

# Create registry (Optional)
#oci artifacts container repository create -c ${mesh_compartment} --display-name ${mesh_name}-homesvc
#oci artifacts container repository create -c ${mesh_compartment} --display-name ${mesh_name}-pricesvc

# BUILD PRICE v1
if [ -d "./price/Wallet" ]; then
  rm -rf ./price/Wallet
fi
if [ -d "./Wallet" ]; then
  rm -rf ./Wallet
fi
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
docker build -t $3/${mesh_name}-pricesvc:v1 .
docker push $3/${mesh_name}-pricesvc:v1
cd ..
# BUILD HOME v1 - STATIC
cd ./home/
cp ./html/pricing/index_static.html ./html/pricing/index.html
docker build -t $3/${mesh_name}-homesvc:v1 .
docker push $3/${mesh_name}-homesvc:v1
# BUILD HOME v2 - DYNAMIC
export admin_link=admin.${dns_domain}
sed -i "s|admin_link|${admin_link}|g" ./html/pricing/index_dynamic.html
cp ./html/pricing/index_dynamic.html ./html/pricing/index.html
docker build -t $3/${mesh_name}-homesvc:v2 .
docker push $3/${mesh_name}-homesvc:v2
rm -f ./html/pricing/index.html
