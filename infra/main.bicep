@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the static site.')
param staticSiteName string

@description('Name of the resource group.')
param resourceGroupName string = resourceGroup().name

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

resource sqlServer 'Microsoft.Sql/servers@2022-03-01' = {
  name: '${staticSiteName}-sqlserver'
  location: location
  properties: {
    version: '12.0'
    administratorLogin: 'yourAdminLogin'
    administratorLoginPassword: 'yourStrongPassword'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-03-01' = {
  name: '${sqlServer.name}/${staticSiteName}-database'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    edition: 'Basic'
    maxSizeBytes: 1073741824 // 1 GB
    requestedServiceObjectiveName: 'Basic'
  }
}

output staticSiteDefaultHostname string = staticSite.properties.defaultHostname
output staticSiteUrl string = 'https://${staticSite.properties.defaultHostname}'
