module Dashboard
  class Usages
    include Skylight::Helpers

    def initialize(organization:)
      @organization = organization
      @rough_data = get_rough_data
    end

    def build_stacked_area_data
      summed_date_grouped_data = sum_date_grouped_data(get_types, @rough_data.group_by { |h| h[:date] })

      flatten_summed_date_grouped_data(summed_date_grouped_data)
    end
    instrument_method :build_stacked_area_data

    def get_types
      @rough_data.map { |datum| datum[:type] }.uniq
    end
    instrument_method :get_types

    private
      def get_rough_data
        # Should be able to do this _all_ in the db if needed
        @organization.usages.where.not(used_at: nil).map do |usage|
          next unless usage&.code

          { type: usage.code.product_category.division.name, date: I18n.l(usage.used_at, format: :mmddyyyy), spent: usage.amount.to_f }
        end.compact
      end
      instrument_method :get_rough_data

      def sum_date_grouped_data(types, date_grouped_data)
        date_grouped_data.each_with_object(Hash.new(0)) do |data_group, summed_date_grouped_data|
          current_date = data_group[0]
          date_usage_hashes = data_group[1]

          types.each do |type|
            date_usage_hashes << { type: type, spent: 0 }
          end

          summed_date_grouped_data[current_date] = date_usage_hashes.each_with_object(Hash.new(0)) do |date_usage_hash, summed_date_usage_hash|
            summed_date_usage_hash[date_usage_hash[:type]] += date_usage_hash[:spent]
          end
        end
      end
      instrument_method :sum_date_grouped_data

      def flatten_summed_date_grouped_data(summed_date_grouped_data)
        summed_date_grouped_data.map do |summed_date_group|
          { date: summed_date_group.first }.merge(summed_date_group.second)
        end.sort_by { |ele| ele[:date] }
      end
      instrument_method :flatten_summed_date_grouped_data
  end
end
