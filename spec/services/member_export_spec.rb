RSpec.describe MemberExport do
  let(:column_headers) { %w[organization_id id name phone email order_id code_id limit_cents deactivated_at created_at external_id product_category_id] }
  subject { described_class.new Member.all, Organization.first }

  describe '#filename' do
    it 'is tagged with the current date' do
      expect(subject.filename).to include Date.current.to_s
    end
  end

  describe '#csv' do
    it 'includes proper headers' do
      expect(subject.csv).to start_with(column_headers.map do |col|
        I18n.t("members.index.columns.#{col}")
      end.join(','))
    end

    it 'includes the proper member data' do
      subject = described_class.new [members(:logan)], organizations(:metova)
      expect(subject.csv).to include [
        members(:logan).id,
        members(:logan).name,
        members(:logan).phone,
        members(:logan).email
      ].join(',')
    end
  end
end
