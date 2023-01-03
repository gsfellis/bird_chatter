param location string
param translatorName string
param pricingTierName string
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource translator 'Microsoft.CognitiveServices/accounts@2022-10-01' = {
  name: translatorName
  location: location
  sku: {
    name: pricingTierName
  }
  kind: 'TextTranslation'
  properties: {
    //restore: true 
  }
}

resource translatorKey1Secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'translatorKey1'
  parent: keyVault
  properties: {
    value: translator.listKeys().key1
  }
}

resource translatorKey2Secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'translatorKey2'
  parent: keyVault
  properties: {
    value: translator.listKeys().key2
  }
}
