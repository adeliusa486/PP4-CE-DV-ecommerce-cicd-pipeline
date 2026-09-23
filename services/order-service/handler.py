import json
import os
import boto3
from models import create_new_order
from events import publish_event

dynamodb = boto3.resource('dynamodb')
ORDERS_TABLE = os.environ['ORDERS_TABLE_NAME']

def lambda_handler(event, context):
    try:
        # 1. Read the incoming request
        body = json.loads(event.get('body', '{}'))
        customer_id = body.get('customer_id')
        items = body.get('items', [])
        total_amount = body.get('total_amount', 0.0)

        # 2. Create the order record
        order = create_new_order(customer_id, items, total_amount)

        # 3. Save it to the DynamoDB database
        table = dynamodb.Table(ORDERS_TABLE)
        table.put_item(Item=order)

        # 4. Shout "OrderCreated" to the EventBridge Message Hub
        publish_event('OrderCreated', order)

        # 5. Return a success response to the customer
        return {
            'statusCode': 201,
            'body': json.dumps({'message': 'Order placed successfully', 'order_id': order['order_id']})
        }

    except Exception as e:
        print(f"Error processing order: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal Server Error'})
        }