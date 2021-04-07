$studentprefix = "lfraile"
$resourcegroupName = "fabmedical-rg-" + $studentprefix
$cosmosDBName = "fabmedical-cdb-" + $studentprefix
$webappName = "fabmedical-web-" + $studentprefix
$planName = "fabmedical-plan-" + $studentprefix
$location1 = "westeurope"
$location2 = "northeurope"

az group create -l $location1 -n $resourcegroupName

#Then create a CosmosDB
az cosmosdb create --name $cosmosDBName `
--resource-group $resourcegroupName `
--locations regionName=$location1 failoverPriority=0 isZoneRedundant=False --locations regionName=$location2 failoverPriority=1 isZoneRedundant=True `
--enable-multiple-write-locations `
--kind MongoDB

#Create a Azure App Service Plan
az appservice plan create --name $planName --resource-group $resourcegroupName --sku S1 --is-linux

#Create a Azure Web App with NGINX container
az webapp create --resource-group $resourcegroupName --plan $planName --name $webappName -i nginx

$appInsights = "fabmedicalai-" + $studentsuffix
az extension add --name application-insights
$ai = az monitor app-insights component create --app $appInsights --location $location1 --kind web -g $resourcegroupName --application-type web --retention-time 120 | ConvertFrom-Json
Write-Host "AI Instrumentation Key=$($ai.instrumentationKey)"