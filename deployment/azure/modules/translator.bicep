param location string
param translatorName string
param pricingTierName string

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

output translatorId string = translator.id
