document.getElementById('history-form').addEventListener('submit', function(event) {
    event.preventDefault();
    const uid = document.getElementById('user-id').value;
    fetchOrderHistory(uid);
});

function fetchOrderHistory(ID) {
    const historyDiv = document.getElementById('order-history');
    const userOrders = orderHistoryDatabase[ID];

    if (userOrders) {
        historyDiv.innerHTML = '<h2>Order History:</h2><ul>' + 
            userOrders.map(order => `
                <li>
                    Order ID: ${order.orderID}, 
                    Buyer ID: ${order.userID}, 
                    Shop ID: ${order.shopID},
                    Item: ${order.itemNames.join(', ')}, 
                    Quantity: ${order.itemQuantities.join(', ')}, 
                    Price: ${order.itemPrices.join(', ')},
                    Total Amount: ${order.totalPrice}, 
                    Payment Method: ${order.paymentMethod},
                    Status: ${order.orderStatus}
                </li>
            `).join('') + 
            '</ul>';
    } else if (error) {
        historyDiv.innerHTML = 'Error fetching order history: ' + error.message;
    } else {
        historyDiv.innerHTML = 'No orders found for this User.';
    }
}