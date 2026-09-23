import sys
import os
import decimal

# Allow pytest to find our models.py file
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import models

def test_create_new_order_basic():
    # Simulate a customer placing an order
    order = models.create_new_order("cust_123", ["laptop"], 1500.00)
    
    # Verify the factory built the order correctly
    assert "order_id" in order
    assert order["customer_id"] == "cust_123"
    assert order["status"] == "PENDING"
    assert "created_at" in order
    
def test_create_new_order_decimal_conversion():
    # Simulate an order with a decimal price
    order = models.create_new_order("cust_999", ["mouse"], 25.50)
    
    # Verify our previous bug is fixed and it safely converts to a Decimal
    assert isinstance(order["total_amount"], decimal.Decimal)
    assert order["total_amount"] == decimal.Decimal("25.5")
