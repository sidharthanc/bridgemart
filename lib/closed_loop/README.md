= Closed Loop
This module contains all the needed transactions for handling gift cards on the 'Closed Loop' system, via First Data

== Activate a Card

Example: Activating a new card with $50 of value.
```
card = ClosedLoop::Transactions::ActivateCard.new(id: rand(9999), limit: 5000, organization_id: 998).perform
```
Note: Use FirstData::Encryption.decrypt_ean("x_HEX_STRING") to decrypt the EAN

== Activate a Physical Card 
Note: This is prolly not what you want, we only support it for full First Data compliance
For this you need a pre-compiled list of card numbers and EANs

```
physical_card = ClosedLoop::Transactions::ActivatePhysicalCard.new(id: rand(9999), amount: 3500, card_number: "7777165453002045", ean: FirstData::Encryption.encrypt_ean("4227")).perform
```

== Void Activation

Example: Voiding a previous activation for card 
```
void_card = ClosedLoop::Transactions::VoidActivateCard.new(card_number: "7777165452274114", ean: FirstData::Encryption.encrypt_ean("XXXX"), amount: 5000).perform
```

== Reload (Add Value) to an existing Card

Example: Adding 8 dollars of value to the card "7777165452269723" (previous example)
```
reload = ClosedLoop::Transactions::ReloadCard.new(card_number: "7777165452269723", ean: FirstData::Encryption.encrypt_ean("XXXX"), amount: 800).perform
```

== Void Reload
void_reload = ClosedLoop::Transactions::VoidReloadCard.new(card_number: "7777165452269723", ean: FirstData::Encryption.encrypt_ean("XXXX"), amount: 800).perform

== Lock / Unlock Card

Example
Locking the card with number "7777165452269723"

```
lock = ClosedLoop::Transactions::LockCard.new(card_number: "7777165452269723", ean: FirstData::Encryption.encrypt_ean("XXXX"), reason: 'lost it').perform
```
Unlock the card with number "7777165452269723"
```
unlock = ClosedLoop::Transactions::UnlockCard.new(card_number: "7777165452269723", ean: FirstData::Encryption.encrypt_ean("XXXX"), reason: 'found it').perform
```
== Balance Inquiry

Example: Checking the Balance on card with number "7777165452269723"
```
balance = ClosedLoop::Transactions::BalanceInquiry.new(card_number: "7777165452269723", ean: FirstData::Encryption.encrypt_ean("XXXX")).perform
```

== Transaction History

Example: Checking the transaction history of card "7777165452269723"
```
transaction_history = ClosedLoop::Transactions::TransactionHistory.new(card_number: "7777165452269723", ean: FirstData::Encryption.encrypt_ean("XXXX")).perform
```

== Close Card
Example: Close the card 
```
closed_card = ClosedLoop::Transactions::CloseCard.new(card_number: "7777165452269723", ean: FirstData::Encryption.encrypt_ean("XXXX")).perform
```