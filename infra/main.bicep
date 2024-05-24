@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the static site.')
param staticSiteName string

@description('Name of the resource group.')
param resourceGroupName string = resourceGroup().name

@description('Name of the SQL Server.')
param sqlServerName string

@description('Name of the SQL Database.')
param sqlDatabaseName string

@description('Administrator username for the SQL Server.')
param adminUsername string

@secure()
@description('Administrator password for the SQL Server.')
param adminPassword string

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

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
  sku: {
    name: 'Free'
    tier: 'Free'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sqlServerName}/${sqlDatabaseName}'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 5242880000
    sampleName: 'AdventureWorksLT'
  }
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  dependsOn: [
    sqlServer
  ]
}

output staticSiteDefaultHostname string = staticSite.properties.defaultHostname
output staticSiteUrl string = 'https://${staticSite.properties.defaultHostname}'
output sqlServerNameOutput string = sqlServer.name
output sqlDatabaseNameOutput string = sqlDatabase.name
