class OrganizationBroker < Importer
  def initialize
    @logger = Logger.new(Rails.root.join('log', 'import.log'))
    @broker_group = PermissionGroup.find_by!(name: 'Broker/TPA')
    @rows_found = 0
    @row_index = 0
    @error_counts = 0
    @current_identifier = ''
    @broker = nil
  end

  def process
    filter_by_legacy_codes
    log_header
    process_organizations_found
    log_footer
  end

  private

    def filter_by_legacy_codes
      @organizations = Organization.where("legacy_identifier ILIKE :string", string: "%-%").order(legacy_identifier: :asc).all
      @rows_found = @organizations.count
    end

    def process_organizations_found
      @organizations.each do |organization|
        identifier = organization.legacy_identifier.split('-')[0]
        find_primary_user(identifier)
        process_organization(organization, identifier)
        @current_identifier = identifier
      end
    end

    def process_organization(organization, _identifier)
      unless @broker.organizations.exists?(organization.id)
        @broker.organizations << organization
        @broker.permission_groups = [@broker_group]
        @broker.save!
        organization.primary_user = @broker
        organization.save!
        @row_index += 1
      end

      print "#{@row_index} processed, #{@error_counts} rejected\r"
    rescue StandardError => e
      @error_counts += 1
      log_exception e, organization
    end

    def find_primary_user(identifier)
      @broker = Organization.find_by!(legacy_identifier: identifier)&.primary_user unless @current_identifier == identifier
    end

    def log_exception(exception, organization)
      @logger.debug "#{exception.message} at Organization # #{organization.id} - #{organization.name}"
      ImportError.create!(
        full_filepath: 'Broker User Process',
        error_message: exception.message,
        csv_row_number: organization.id,
        csv_record: organization.as_json
      )
    end

    def log_header
      hrule
      log_and_print "Organizations Found: #{@rows_found}"
      hrule
    end

    def log_footer
      print "\n"
      log_and_print "#{@row_index - @error_counts} organizations processed"
      log_and_print "#{@error_counts} organizations with errors, not processed"
    end
end
