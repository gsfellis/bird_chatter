param keyVaultName string
param location string

var tenantId = subscription().tenantId

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId

    enableRbacAuthorization: false
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    //enablePurgeProtection: false
    enableSoftDelete: false
    createMode: 'default'
    accessPolicies: [
      {
        objectId: '4af241bf-94d0-4e08-982e-6a403f1ecc34'
        tenantId: tenantId
        permissions: {
          certificates: ['all']
          keys: ['all']
          storage: ['all']
          secrets: ['all']
        }
      }
    ]
  }
}
