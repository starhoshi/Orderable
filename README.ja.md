# Orderable

Orderable は簡単に決済が実行できるライブラリです。

## 手順

Orderable の Protocol を実装し、[orderable.ts](https://github.com/starhoshi/Orderable.ts) を Cloud Functions for Firebase に deploy する必要があります。


### 0. Install

Podfile:

```
pod 'Orderable'
```

### 1. Protocol

[Orderable/Model\.swift](https://github.com/starhoshi/Orderable/blob/master/SampleModel/Model.swift) を参考にモデルの定義をしてください。

### 2. Deploy Cloud Functions

[orderable.ts](https://github.com/starhoshi/Orderable.ts) を Deploy してください。

### 3. Pay an order

Sample code is [here](https://github.com/starhoshi/Orderable/blob/master/Demo/ViewController.swift).

```swift
user.stripeCustomerID = "cus_....."
user.update()

...

order.stripeCardID = "card_....."
order.paymentStatus = OrderPaymentStatus.paymentRequested
order.update() // exec cloud functions

import Pring
var disposer: Disposer<Order>?
self?.disposer = Order.listen(order.id) { order, error in
  if order.stripeChargeID != nil {
    // stripe charge completed.
  }
}
```

# License

MIT

