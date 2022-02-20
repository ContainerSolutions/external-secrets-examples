!# /bin/bash

TENANT_ID="DEFINE ME HERE"
RESOURCE_GROUP="MyKeyVaultResourceGroup"
LOCATION="westus"
VAULT_NAME="eso-vault-example"
SECRET_NAME="example-externalsecret-key"
SECRET_VAlUE="This is our secret now"
APP_NAME="ExtSectret Query App"
APP_PASSWORD="ThisisMyStrongPassword"

az group create --location $LOCATION --name $RESOURCE_GROUP
az keyvault create --name $VAULT_NAME --resource-group $RESOURCE_GROUP
az keyvault secret set --name $SECRET_NAME --vault-name $VAULT_NAME --value "$SECRET_VAlUE"

APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId | tr -d \")
SERVICE_PRINCIPAL=$(az ad sp create --id $APP_ID --query objectId | tr -d \")

az ad app permission add --id $APP_ID --api-permissions f53da476-18e3-4152-8e01-aec403e6edc0=Scope --api cfa8b339-82a2-471a-a3c9-0fc0be7a4093
az ad app credential reset --id $APP_ID --password "$APP_PASSWORD"
az keyvault set-policy --name $VAULT_NAME --object-id $SERVICE_PRINCIPAL --secret-permissions get

kubectl create secret generic azure-secret-sp --from-literal=ClientID=$APP_ID --from-literal=ClientSecret=$APP_PASSWORD
