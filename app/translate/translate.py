import json
import logging
import os
import sys
import uuid

import azure.functions as func
import requests

# Key should be added as a value in Azure Key Vault
# and retrieved as an Application Variable in App Service
key = os.getenv('TranslatorKey')
endpoint = "https://api.cognitive.microsofttranslator.com"

# location, also known as region.
# required if you're using a multi-service or regional (not global) resource. It can be found in the Azure portal on the Keys and Endpoint page.
location = "eastus"

path = '/translate'
constructed_url = endpoint + path

headers = {
    'Ocp-Apim-Subscription-Key': key,
    # location required if you're using a multi-service or regional (not global) resource.
    'Ocp-Apim-Subscription-Region': location,
    'Content-type': 'application/json',
    'X-ClientTraceId': str(uuid.uuid4())
}

def call_translate(body):
    '''
    Operation 	Maximum Size of Array Element 	Maximum Number of Array Elements 	Maximum Request Size (characters)
    Translate 	50,000 	1,000 	50,000
    '''
    params = {
        'api-version': '3.0',
        'from': body.get('from'),
        'to': body.get('to')
    }

    body = [{
        'text': body.get('text')
    }]

    response = requests.post(constructed_url, params=params, headers=headers, json=body)   

    return response.json()
    

def validate_body(body):
    pass

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')    
    
    try:
        req_body = req.get_json()
    except ValueError:
        raise ValueError('Expected JSON body')

    res = call_translate(req_body)

    logging.info(res)

    return func.HttpResponse(json.dumps(res))
