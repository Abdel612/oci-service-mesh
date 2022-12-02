# $1 = db name
# $2 = db password
# $3 = DNS domain name
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  exit
fi
if [ ! -f "instantclient-basic-linux.x64-21.7.0.0.0dbru.zip" ]; then
  echo "Download instantclient-basic-linux.x64-21.7.0.0.0dbru.zip from OTN at https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip"
  exit
else
    cp instantclient-basic-linux.x64-21.7.0.0.0dbru.zip ./price/
fi

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
docker build -t ${ocir}/${mesh_name}-pricesvc:v1 .
docker push ${ocir}/${mesh_name}-pricesvc:v1
cd ..
# BUILD HOME v1 - STATIC
cd ./home/
cp ./html/pricing/index_static.html ./html/pricing/index.html
docker build -t ${ocir}/${mesh_name}-homesvc:v1 .
docker push ${ocir}/${mesh_name}-homesvc:v1
# BUILD HOME v2 - DYNAMIC
export admin_link=admin.$3
sed -i "s|admin_link|${admin_link}|g" ./html/pricing/index_dynamic.html
cp ./html/pricing/index_dynamic.html ./html/pricing/index.html
docker build -t ${ocir}/${mesh_name}-homesvc:v2 .
docker push ${ocir}/${mesh_name}-homesvc:v2
rm -f ./html/pricing/index.html
