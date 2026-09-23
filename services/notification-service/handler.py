import json

def lambda_handler(event, context):
    try:
        # What kind of message did we receive?
        detail_type = event.get('detail-type')
        order_data = event.get('detail', {})
        order_id = order_data.get('order_id')
        
        # 1. Pretend to send an email to the customer based on the event type
        if detail_type == 'OrderConfirmed':
            print(f"EMAIL SENT: Your order {order_id} has been fully confirmed and is shipping soon!")
            
        elif detail_type == 'OrderCancelled':
            print(f"EMAIL SENT: We are sorry, but your order {order_id} was cancelled. Your card was not charged.")
            
        else:
            print(f"Received unknown event: {detail_type}")

        return {"status": "success"}

    except Exception as e:
        print(f"Error sending notification: {str(e)}")
        raise e