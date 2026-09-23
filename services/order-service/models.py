import uuid
import datetime
import decimal

def create_new_order(customer_id, items, total_amount):
    return {
        'order_id': str(uuid.uuid4()),
        'customer_id': customer_id,
        'items': items,
        'total_amount': decimal.Decimal(str(total_amount)),
        'status': 'PENDING',
        'created_at': datetime.datetime.utcnow().isoformat()
    }
