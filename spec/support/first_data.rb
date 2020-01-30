module FirstDataTestHelper
  StubbedFaradayResponse = Struct.new(:body)
  def first_data_response(fixture)
    FirstData::Response.new(StubbedFaradayResponse.new(file_fixture(fixture).read))
  end
end

# Make sure MWK is assigned.
# ClosedLoop::Transactions::AssignMerchantKey.new(key_id: FirstData::Client.credentials[:active_merchant_key_id], merchant_key: FirstData::Client.credentials[:merchant_working_key_encrypted])
