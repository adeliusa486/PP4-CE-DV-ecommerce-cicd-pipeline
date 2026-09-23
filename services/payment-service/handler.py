import json
import os
import boto3
import random
from models import create_payment_record
from events import publish_event

dynamodb = boto3.resource('dynamodb')
PAYMENTS_TABLE = os.environ['PAYMENTS_TABLE_NAME']

def lambda_handler(event, context):
    try:
        # 1. Read the message details that came from EventBridge
        order_data = event.get('detail', {})
        order_id = order_data.get('order_id')
        amount = order_data.get('total_amount')

        # 2. Simulate processing a credit card (80% chance of success)
        is_success = random.random() < 0.8
        
        if is_success:
            status = "SUCCEEDED"
            reason = "Payment processed successfully"
            event_type = "PaymentSucceeded"
        else:
            status = "FAILED"
            reason = "Insufficient funds"
            event_type = "PaymentFailed"

        # 3. Save the result to the Payments database
        payment_record = create_payment_record(order_id, amount, status, reason)
        table = dynamodb.Table(PAYMENTS_TABLE)
        table.put_item(Item=payment_record)

        # 4. Tell EventBridge whether the payment succeeded or failed
        publish_event(event_type, payment_record)
        
        print(f"Processed payment for order {order_id}. Status: {status}")
        return {"status": "success"}

    except Exception as e:
        print(f"Error processing payment: {str(e)}")
        raise e  # We raise the error so AWS knows it failed and can send it to the DLQ (Holding Pen)