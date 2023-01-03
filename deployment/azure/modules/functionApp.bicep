param location string
param appServiceName string
param functionAppName string
param storageAccountName string
param translatorId string


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource appService 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServiceName
  location: location
  kind: 'linux'
  sku : {
    tier: 'Dynamic'
    name: 'Y1'
  }
  properties: {
    reserved: true  
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'  
  properties: {
    httpsOnly: true
    clientAffinityEnabled: true
    serverFarmId: appService.id
    siteConfig: {
      pythonVersion: '3.9'
      linuxFxVersion: 'Python|3.9'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }        
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id,storageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id,storageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }        
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'TranslatorKey'
          value: listKeys(translatorId, '2022-12-01').key1
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
    }
  }
}

resource functionAppBinding 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  parent: functionApp
  name: '${functionApp.name}.azurewebsites.net'
  properties: {
    siteName: functionApp.name
    hostNameType: 'Verified'
  }
}
