import json
import os
import random
from events import publish_event

def lambda_handler(event, context):
    try:
        # 1. Read the message from the Hub
        order_data = event.get('detail', {})
        order_id = order_data.get('order_id')
        items = order_data.get('items', [])

        print(f"Checking inventory for order {order_id}...")

        # 2. Simulate checking the warehouse database (80% chance we have it in stock)
        in_stock = random.random() < 0.8
        
        if in_stock:
            print("Items are in stock! Reserving inventory.")
            # In a real app, we would update the DynamoDB Products table here to reduce stock count
            publish_event('InventoryReserved', {'order_id': order_id, 'status': 'RESERVED'})
        else:
            print("Items are OUT OF STOCK!")
            publish_event('InventoryFailed', {'order_id': order_id, 'reason': 'Out of stock'})

        return {"status": "success"}

    except Exception as e:
        print(f"Error checking inventory: {str(e)}")
        raise e