require 'csv'

UNKNOWN = 'Unknown'.freeze

class Importer
  def initialize(filepath, dryrun: false)
    return file_error unless filepath.present?

    @full_filepath = File.expand_path filepath
    @dryrun = dryrun
    @logger = Logger.new(Rails.root.join('log', 'import.log'))
    @row_index = 0
    @error_counts = 0
  end

  def import
    log_header

    ActiveRecord::Base.transaction do
      import_records
      rollback if dry_run?
    end
  ensure
    log_footer
  end

  private
    def import_records
      CSV.foreach(@full_filepath, headers: true) do |row|
        import_record row
      end
    end

    def import_record(row)
      print "#{@row_index} rows processed, #{@error_counts} rejected\r"
      @row_index += 1
      create_schema_records row
    rescue StandardError => e
      @error_counts += 1
      log_exception e, row
    end

    def log_exception(exception, row)
      @logger.debug "#{exception.message} at row # #{@row_index + 1}"
      ImportError.create!(
        full_filepath: @full_filepath,
        error_message: exception.message,
        csv_row_number: @row_index + 1,
        csv_record: row.to_h.as_json
      )
    end

    def rollback
      @logger.info 'Dry run enabled; rolling back entire import'
      raise ActiveRecord::Rollback
    end

    def file_error
      raise 'A valid filepath is required'
    end

    def dry_run?
      @dryrun
    end

    def log_header
      hrule
      log_and_print "Import file: #{@full_filepath} for #{__FILE__}"
      hrule
    end

    def log_footer
      print "\n"
      log_and_print "#{@row_index - @error_counts} records imported"
      log_and_print "#{@error_counts} records with errors, not imported"
    end

    def hrule
      log_and_print '-' * 78
    end

    def log_and_print(message)
      @logger.info message
      print "#{message}\n"
    end

    def create_schema_records(_)
      raise 'You must define the create_schema_records'
    end
end
