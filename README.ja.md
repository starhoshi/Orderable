<p align="center">
    <img src="https://raw.githubusercontent.com/starhoshi/orderable.ts/master/docs/logo.png" width='180px' />
</p>

# Orderable

<b>⚠️ Orderable は現在開発中です ⚠️</b>

Orderable は Cloud Functions for Firebase と連携し、決済が簡単に実行できるライブラリです。  
EC に必要な在庫チェック、購入処理、購入後の履歴作成などを実行できます。

Orderable の Protocol を実装し、[orderable.ts](https://github.com/starhoshi/Orderable.ts) を Cloud Functions for Firebase に deploy する必要があります。


## Installation

Podfile:

```
pod 'Orderable'
```

## Usage

### 1. Protocol

[Orderable/Model\.swift](https://github.com/starhoshi/Orderable/blob/master/SampleModel/Model.swift) を参考に、あなたのプロジェクトで必要な Model の定義をしてください。

* User
  * 購入者
* Shop
  * 販売者
* Product
  * 商品の概念。
* SKU
  * 商品の実態。在庫や値段などを持つ。
* Order
  * 注文。ユーザが支払う金額や支払い方法などを持つ。
* OrderShop
  * Shop ごとの注文情報。
* OrderSKU
  * 注文された商品。購入数などを持つ。

### 2. Deploy Cloud Functions

[orderable.ts](https://github.com/starhoshi/Orderable.ts) を Cloud Functions に Deploy してください。

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
