import boto3
import json
import os
import decimal

eventbridge = boto3.client('events')
EVENT_BUS_NAME = os.environ['EVENT_BUS_NAME']

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def publish_event(detail_type, detail_data):
    response = eventbridge.put_events(
        Entries=[
            {
                'Source': 'ecommerce.order-service',
                'DetailType': detail_type,
                'Detail': json.dumps(detail_data, cls=DecimalEncoder),
                'EventBusName': EVENT_BUS_NAME
            }
        ]
    )
    return response
