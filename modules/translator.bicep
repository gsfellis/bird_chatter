param location string
param translatorName string
param pricingTierName string

resource textTranslator 'Microsoft.CognitiveServices/accounts@2022-10-01' = {
  name: translatorName
  location: location
  sku: {
    name: pricingTierName
  }
  kind: 'TextTranslation'
}
