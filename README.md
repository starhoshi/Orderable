<p align="center">
    <img src="https://raw.githubusercontent.com/starhoshi/orderable.ts/master/docs/logo.png" width='180px' />
</p>

# Orderable

<b>⚠️ Orderable is currently under development. ⚠️</b>

for japanese: [README\.ja\.md](https://github.com/starhoshi/Orderable/blob/master/README.ja.md)

orderable.ts is a CocoaPods library that works with Cloud Functions for Firebase and can easily execute payment.

EC requires a lot of processing. For example, check number of stocks, payment process, create history, and so on. Orderable exec these troublesome tasks.

For Server Side (Cloud Functions for Firebase): [starhoshi/orderable.ts](https://github.com/starhoshi/orderable.ts)

## Installation

Podfile:

```
pod 'Orderable'
```

## Usage

### 1. Protocol

You need to define the necessary Model in your project.

Required protocol is [here](https://github.com/starhoshi/Orderable/blob/master/Orderable/Order.swift), sample model definition is [here](https://github.com/starhoshi/Orderable/blob/master/SampleModel/Model.swift).

* User
  * Buyer
* Shop
  * Seller
* Product
  * Product concept.
* SKU
  * Entity of the product. Have inventory and price etc.
* Order
  * Order have payment amount and payment method etc.
* OrderShop
  * Order information for each shop.
* OrderSKU
  * The item ordered. Have quantity etc.


### 2. Deploy

Deploy [orderable.ts](https://github.com/starhoshi/Orderable.ts) to Cloud Functions.

### 3. Pay an order

Sample code is [here](https://github.com/starhoshi/Orderable/blob/master/Demo/ViewController.swift). orderable.ts starts when `order.paymentStatus = OrderPaymentStatus.paymentRequested` and update is done.

```swift
let order = Order()
order.amount = 1000
let stripe = Stripe()
stripe.customerID = "new_cus"
stripe.cardID = "new_card"
order.stripe = stripe
order.paymentStatus = OrderPaymentStatus.created
order.save()

...

// functions trigger
order.paymentStatus = OrderPaymentStatus.paymentRequested
order.update() // start cloud functions
```

### 4. Result

When purchase processing is completed, order.neoTask.status === 1 will be set. That is a sign of success. Observe the order and wait for the process to complete.

```swift
import Pring

var disposer: Disposer<Order>?
self?.disposer = Order.listen(order.id) { order, error in
  if order.neoTask.status === 1, order.stripeChargeID != nil {
    // stripe charge completed.
  }
}
```

## Error

Detailed errors are listed [here](https://github.com/starhoshi/orderable.ts#neotask).
You need to handle error by each error type.

On the client side, handle the following two errors.

* invalid
  * Need to fix properties on the client side.
* fatal
  * Have to check and correct the data directly.

## LICENSE

MIT
