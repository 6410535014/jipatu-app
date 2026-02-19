function placeOrder(userID, shopID, itemNames, itemQuantities, itemPrices) {


    const totalPrice = 0;
    for (const index of itemNames) {
        totalPrice += itemPrices[index] * itemQuantities[index];

    }

    db.collection("orders").add({
        orderID: docRef.id,
        userID: userID,
        shopID: shopID,
        itemNames: itemNames,
        itemQuantities: itemQuantities,
        itemPrices: itemPrices,
        totalPrice: totalPrice,
        status: "pending",
        createAt: firebase.firestore.FieldValue.serverTimestamp()
    })
    .then((docRef) => {
        console.log("Order placed with ID:", docRef.id);
    })
    .catch((error) => {
        console.error("Error placing order:", error);
    });
}