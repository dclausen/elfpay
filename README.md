# ElfPay
Introducing ElfPay, the easiest and fastest way to receive money in Middle-earth. It's the best way to buy all your orc hunting needs. Coming to a storefront in Rivendell soon!

This PR adds the following new features:

- creating orders
- retrieving existing orders
- searching for orders by customer email
- applying payments to an existing order
- creating an order and receiving a payment within a single transaction

## Getting started
```
git clone https://github.com/dclausen/elfpay
cd elfpay
mix deps.get
mix ecto.setup
mix test
```

- [x] Typespecs added to public API methods and all are passing.
- [x] Tests added to public API methods and all are passing.
- [x] All files formatted via ```mix format```.
