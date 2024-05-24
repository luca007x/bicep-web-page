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

output staticSiteDefaultHostname string = staticSite.properties.defaultHostname
output staticSiteUrl string = 'https://${staticSite.properties.defaultHostname}'
