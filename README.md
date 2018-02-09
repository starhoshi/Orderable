<p align="center">
    <img src="https://raw.githubusercontent.com/starhoshi/orderable.ts/master/docs/logo.png" width='180px' />
</p>

# Orderable

<b>⚠️ Orderable is currently under development. ⚠️</b>

for japanese: [README\.ja\.md](https://github.com/starhoshi/Orderable/blob/master/README.ja.md)

orderable.ts is a CocoaPods library that works with Cloud Functions for Firebase and can easily execute payment.

EC requires a lot of processing. For example, check number of stocks, payment process, create history, and so on. Orderable exec these troublesome tasks.

For Server Side (Cloud Functions for Firebase): [starhoshi/Orderable](https://github.com/starhoshi/Orderable)

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

Sample code is [here](https://github.com/starhoshi/Orderable/blob/master/Demo/ViewController.swift). `order.paymentStatus = OrderPaymentStatus.paymentRequested` にして update すると Cloud Functions が動き出します。

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

Cloud Functions が成功すると、 `order.neoTask.status === 1` がセットされます。 order を observe して処理が完了するのを待ってください。

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

詳細なエラーは [starhoshi/orderable\.ts#Error](https://github.com/starhoshi/orderable.ts#neotask) に記載してありますので、それぞれのエラーに対しクライアント側で適切にハンドリングしてください。

クライアント側が意識するべきエラーは以下の2つです。

* invalid
  * クライアント側で修正が必要なエラー
* fatal
  * 開発者が手動で対応しなければならないもの

## LICENSE

MIT
