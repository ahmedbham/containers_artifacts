
docker pull mcr.microsoft.com/mssql/server:2017-latest
docker network create docker-network
export MSSQL_SA_PASSWORD='Gmg99921'
sudo docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Gmg99921" \
   -p 1433:1433 --name sql1 --hostname sql1 \
   --network docker-network \
   -d \
   mcr.microsoft.com/mssql/server:2017-latest

docker exec -it sql1 "bash"

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Gmg99921"
create database mydrivingDB

git clone https://github.com/microsoft/openhack
cd openhack
cd byos/containers/deploy
./deploy.sh

login to portal
go to acr
get userid/password

az login
docker login registry.azurecr.io

docker run --network docker-network -e SQLFQDN=sql1 -e SQLUSER=SA -e SQLPASS=Gmg99921 -e SQLDB=mydrivingDB registry.azurecr.io/dataload:1.0

move dockerfile_3 to src/poi
cd src/poi
rename dockerfile_3 to dockerfile

update dockerfile:
ENV SQL_USER="SA" \
    SQL_PASSWORD="" \
    SQL_SERVER="sql1" \
    SQL_DBNAME="mydrivingDB" \
    WEB_PORT=8080 \
    WEB_SERVER_BASE_URI="http://0.0.0.0" \
    ASPNETCORE_ENVIRONMENT="Local" \
    CONFIG_FILES_PATH="/secrets"


docker build -t poi .
docker tag poi registry.azurecr.io/tripinsights/poi:1.0
docker push registry.azurecr.io/tripinsights/poi:1.0

docker build -t tripviewer .
docker tag tripviewer registry.azurecr.io/tripinsights/tripviewer:1.0
docker push registry.azurecr.io/tripinsights/tripviewer:1.0

docker run --network docker-network -d -p 8080:8080 --name poi poi:latest

curl -i -X GET 'http://localhost:8080/api/poi'

docker tag tripinsights/user-java:1.0 registry.azurecr.io/tripinsights/user-java:1.0
docker push registry.azurecr.io/tripinsights/user-java:1.0

cp dockerfiles/Dockerfile_0 src/user-java/Dockerfile

az configure --defaults group=teamResources
az aks create --name myAKS --enable-addons http_application_routing --generate-ssh-keys
az aks update -n myAKS --enable-managed-identity
az aks update --attach-acr registry -n myAKS

kubectl create deploy poi --image=registry.azurecr.io/tripinsights/poi:1.0 --replicas=1 --port=80 --dry-run=client -o yaml > poi-deploy.yaml

kubectl expose deployment/poi --port=8080 --target-port=80 --name poi-service --dry-run=client -o yaml > poi-service.yaml

k port-forward svc/poi-service 8080:8080

kubectl create deploy trips --image=registry.azurecr.io/tripinsights/trips:1.0 --replicas=1 --dry-run=client -o yaml > trips-deploy.yaml

kubectl expose deployment/trips --port=8080 --target-port=80 --name trips-service --dry-run=client -o yaml > trips-service.yaml

kubectl create deploy tripviewer --image=registry.azurecr.io/tripinsights/tripviewer:1.0 --replicas=1 --dry-run=client -o yaml > tripviewer-deploy.yaml

kubectl expose deployment/tripviewer --port=8080 --target-port=80 --name tripviewer-service --dry-run=client -o yaml > tripviewer-service.yaml

kubectl create deploy user-java --image=registry.azurecr.io/tripinsights/user-java:1.0 --replicas=1 --dry-run=client -o yaml > user-java-deploy.yaml

kubectl expose deployment/user-java --port=8080 --target-port=80 --name user-java-service --dry-run=client -o yaml > user-java-service.yaml

kubectl create deploy userprofile --image=registry.azurecr.io/tripinsights/userprofile:1.0 --replicas=1 --dry-run=client -o yaml > userprofile-deploy.yaml




kubectl create secret generic sql-conn --from-literal=SQL_PASSWORD=cV0se0Qo1 \
--from-literal=SQL_USER=ssql \
--from-literal=SQL_SERVER=ssql.database.windows.net -n api

create ns web
create ns api

subnet_id=$(az network vnet subnet list \
    --vnet-name vnet \
    --query "[0].id" --output tsv)

az aks create \
    --name myAKSCluster \
    --network-plugin azure \
    --vnet-subnet-id $subnet_id \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.1.0.10 \
    --service-cidr 10.1.0.0/24 \
    --generate-ssh-keys \
    --enable-managed-identity \
    --enable-aad \
    --location centralus


NAMESPACE=ingress-basic

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

curl -i -X GET 'http://http://20.59.104.132/api/poi' 

az aks disable-addons --addons http_application_routing --name myAKS

az aks enable-addons --addons azure-keyvault-secrets-provider --name myAKS

vmssname=aks-nodepool1-24726997-vmss
az vmss identity show -g MC_teamResources_myAKS_westus  -n aks-nodepool1-24726997-vmss -o yaml
principalId=

az aks show -n myAKS --query "addonProfiles.azureKeyvaultSecretsProvider.identity.clientId" -o tsv
principalid=  
clientID=

keyvault_name=ahmedbhamkeyvault2
az keyvault create -n $keyvault_name  -l westus
az keyvault set-policy -n $keyvault_name --secret-permissions get --object-id $principalId

az keyvault secret set --vault-name $keyvault_name -n SQL-USER --value sqladminrVy7760

az keyvault secret set --vault-name $keyvault_name -n SQL-PASSWORD --value cV0se0Qo1
az keyvault secret set --vault-name $keyvault_name -n SQL-SERVER --value sqlserverrvy7760.database.windows.net

az aks nodepool upgrade --node-image-only --cluster-name myAKS -n nodepool1

az aks update -n myAKS --api-server-authorized-ip-ranges 98.37.22.96/32

az aks enable-addons --addons azure-policy --name MyAKS

VNET_NAME=aks-vnet-13448142
subnet_name=aks-subnet
FWSUBNET_NAME="AzureFirewallSubnet"
RG=MC_teamResources_myAKS_westus
PREFIX="aks-egress"
FWNAME="${PREFIX}-fw"
FWPUBLICIP_NAME="${PREFIX}-fwpublicip"
FWIPCONFIG_NAME="${PREFIX}-fwconfig"
FWROUTE_TABLE_NAME="${PREFIX}-fwrt"
FWROUTE_NAME="${PREFIX}-fwrn"
FWROUTE_NAME_INTERNET="${PREFIX}-fwinternet"
LOC=westus
AKSSUBNET_NAME=aks-subnet

az network vnet subnet create \
    --vnet-name $VNET_NAME \
    --resource-group $RG \
    --name $FWSUBNET_NAME \
    --address-prefix 10.232.1.0/24

az network public-ip create -g $RG -n $FWPUBLICIP_NAME --sku "Standard"

az extension add --name azure-firewall

az network firewall create -g $RG -n $FWNAME -l $LOC --enable-dns-proxy true

# Configure Firewall IP Config

az network firewall ip-config create -g $RG -f $FWNAME -n $FWIPCONFIG_NAME --public-ip-address $FWPUBLICIP_NAME --vnet-name $VNET_NAME

FWPUBLIC_IP=$(az network public-ip show -g $RG -n $FWPUBLICIP_NAME --query "ipAddress" -o tsv)
FWPRIVATE_IP=$(az network firewall show -g $RG -n $FWNAME --query "ipConfigurations[0].privateIpAddress" -o tsv)

# Create UDR and add a route for Azure Firewall

az network route-table create -g $RG -l $LOC --name $FWROUTE_TABLE_NAME
az network route-table route create -g $RG --name $FWROUTE_NAME --route-table-name $FWROUTE_TABLE_NAME --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $FWPRIVATE_IP
az network route-table route create -g $RG --name $FWROUTE_NAME_INTERNET --route-table-name $FWROUTE_TABLE_NAME --address-prefix $FWPUBLIC_IP/32 --next-hop-type Internet

az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr' -n 'apiudp' --protocols 'UDP' --source-addresses '*' --destination-addresses "AzureCloud.$LOC" --destination-ports 1194 --action allow --priority 100
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr' -n 'apitcp' --protocols 'TCP' --source-addresses '*' --destination-addresses "AzureCloud.$LOC" --destination-ports 9000

az network vnet subnet update -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --route-table $FWROUTE_TABLE_NAME
SUBNETID=$(az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv)

# Get your AKS Resource ID
AKS_ID=$(az aks show -n MyManagedCluster --query id -o tsv)


az role assignment create --role "Azure Kubernetes Service RBAC Admin" --assignee  --scope $AKS_ID
