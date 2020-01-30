describe Dashboard::Usages do
  let(:organization) { organizations(:metova) }
  let(:code) { codes(:logan) }

  subject { described_class.new organization: organization }

  xdescribe 'build_stacked_area_data' do
    it 'should return usable data for d3' do
      expect(subject.build_stacked_area_data).to eq [{ :date => "02/02/2002", "Bridge Vision" => 200.0 }]
    end
  end

  xdescribe 'get_types' do
    it 'should return the types of usages' do
      expect(subject.get_types).to eq ['Bridge Vision']
    end
  end
end
