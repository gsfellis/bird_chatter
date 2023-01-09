param location string
param appServiceName string
param functionAppName string
param applicationInsightsName string
param storageAccountName string
param keyVaultName string


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
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
  identity: {
    type: 'SystemAssigned'
  }
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
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'TRANSLATOR_KEY_1'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=translatorKey1)'
        }
        {
          name: 'TRANSLATOR_KEY_2'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=translatorKey2)'
        }
        {
          name: 'STORAGE_KEY_1'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=storageKey1)'
        }
        {
          name: 'STORAGE_KEY_2'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=storageKey2)'
        }
        {
          name: 'STORAGE_CONN_1'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=storageConn1)'
        }
        {
          name: 'STORAGE_CONN_2'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=storageConn2)'
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

resource keyVaultPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'replace'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: functionApp.identity.principalId
        tenantId: subscription().tenantId
        permissions: {
          secrets: [ 'get' ]
        }
      }
    ]
  }
}


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
