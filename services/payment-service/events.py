import boto3
import json
import os

eventbridge = boto3.client('events')
EVENT_BUS_NAME = os.environ['EVENT_BUS_NAME']

def publish_event(detail_type, detail_data):
    response = eventbridge.put_events(
        Entries=[
            {
                'Source': 'ecommerce.payment-service',
                'DetailType': detail_type,
                'Detail': json.dumps(detail_data),
                'EventBusName': EVENT_BUS_NAME
            }
        ]
    )
    return response