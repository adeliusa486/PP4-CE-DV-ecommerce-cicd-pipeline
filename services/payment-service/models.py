import uuid
import datetime

def create_payment_record(order_id, amount, status, reason=""):
    return {
        "payment_id": str(uuid.uuid4()),
        "order_id": order_id,
        "amount": str(amount),
        "status": status,
        "reason": reason,
        "created_at": datetime.datetime.utcnow().isoformat()
    }