describe EML::BatchExpireCardJob do
  let(:code) { codes(:logan) }
  let(:order) { code.order }

  describe 'perform' do
    context 'Expire cards' do
      it 'does not expire any cards today' do
        expect { subject.perform }.to enqueue_job(EML::ExpireCardJob).exactly(0)
      end

      it 'expires one card' do
        # code.order.update! ends_on: 367.days.ago
        order.ends_on = 367.days.ago
        order.save(validate: false)

        expect { subject.perform }.to enqueue_job(EML::ExpireCardJob).exactly(Code.with_card_type(:eml).count)
      end
    end
  end
end
