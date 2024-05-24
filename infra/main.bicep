@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the static site.')
param staticSiteName string

@description('Name of the resource group.')
param resourceGroupName string = resourceGroup().name

@description('Name of the Function App.')
param functionAppName string

@description('Storage account name for the Function App.')
param storageAccountName string

resource staticSite 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticSiteName
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: 'https://github.com/luca007x/bicep-web-page/'
    branch: 'main'
    buildProperties: {
      appLocation: '/'
      outputLocation: 'build'
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${functionAppName}-plan'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource staticSiteApi 'Microsoft.Web/staticSites/functions@2022-03-01' = {
  name: '${staticSiteName}/default'
  properties: {
    functionAppResourceId: functionApp.id
  }
}

output staticSiteDefaultHostname string = staticSite.properties.defaultHostname
output staticSiteUrl string = 'https://${staticSite.properties.defaultHostname}'
output functionAppNameOutput string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
