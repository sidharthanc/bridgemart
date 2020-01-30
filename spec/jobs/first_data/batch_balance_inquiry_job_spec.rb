describe FirstData::BatchBalanceInquiryJob do
  describe 'perform' do
    it 'enqueues a transaction job for each active card' do
      expect { subject.perform }.to enqueue_job(FirstData::BalanceInquiryJob).exactly(Code.with_card_type(:first_data).count)
    end

    context 'with missing external_id for code' do
      before { Code.update_all(external_id: nil) }

      it 'does not enqueue a transaction job' do
        expect { subject.perform }.to_not enqueue_job(FirstData::BalanceInquiryJob)
      end
    end

    # TODO: This branch doesn't have Deactivatable yet
    xit 'does not enqueue a job for inactive codes'
  end
end
