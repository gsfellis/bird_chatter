@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(5)
@maxLength(30)
param solutionName string = 'bird-chatter-${uniqueString( resourceGroup().id )}'

@description('The Azure region into which the resources should be deployed.')
param location string = 'eastus'

@description('Document Translator Pricing Tier')
@allowed([
  'S1'
  'S2'
  'S3'
  'S4'
])
param translatorPricingTier string = 'S1'

var keyVaultName = 'kv-${uniqueString( resourceGroup().id )}'
module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}

var translatorName = '${environmentName}-${solutionName}-translator'
module translator 'modules/translator.bicep' = {
  name: 'translator'
  params: {
    location: location
    translatorName: translatorName
    pricingTierName: translatorPricingTier
    keyVaultName: keyVaultName
  }
  dependsOn: [
    keyVault
  ]
}

var storageAccountName = '${environmentName}birdchattersa'
module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountSkuName: 'Standard_LRS'    
    storageAccountAccessTier: 'Hot'
  }
}

var functionAppName = '${environmentName}birdchatterfa'
var appServiceName = '${environmentName}birdchatteras'
module functionApp 'modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    appServiceName: appServiceName
    functionAppName: functionAppName
    storageAccountName: storageAccount.outputs.name
    keyVaultName: keyVaultName
  }
  dependsOn: [
    keyVault
    storageAccount
    translator
  ]
}
