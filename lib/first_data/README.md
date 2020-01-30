= ENCRYPTION

== Changing The Merchant Key in use

mwk_gen = FirstData::Encryption.generate_merchant_working_key(SHARED_SECRET)
key_id = 106  # some numeric id that hasn't been used. We should prolly track these # TODO ?

# Assign new merchant key
assignment = ClosedLoop::Transactions::AssignMerchantKey.new(key_id: 100, merchant_key: FirstData::Client.credentials[:merchant_working_key_encrypted])

# Then go update the credentials to make sure the merchant_working_key, encrypted, and key_id are all set correct

== Registration
FirstData::Services::Registration.new.perform  # returns DID
# update DID in creds
# new console session to pick up new creds
FirstData::Services::Activation.new.perform