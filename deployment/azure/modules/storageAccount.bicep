param location string
param storageAccountName string
param storageAccountSkuName string
param storageAccountAccessTier string
param keyVaultName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: storageAccountAccessTier
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
}

resource sourceContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'source'
  parent: blobService
}

resource targetContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'target'
  parent: blobService
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource storageKey1Secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'storageKey1'
  parent: keyVault
  properties: {
    value: storageAccount.listKeys().keys[0].value
  }
}

resource storageKey2Secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'storageKey2'
  parent: keyVault
  properties: {
    value: storageAccount.listKeys().keys[1].value
  }
}

output name string = storageAccount.name
