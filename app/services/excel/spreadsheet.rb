require 'creek'

module Excel
  class Spreadsheet
    include Enumerable

    def initialize(file)
      @file = file
    end

    def each(&block)
      data.each(&block)
    end

    def header
      @header ||= rows.first
    end

    def data
      rows.drop(1).map do |row|
        row.transform_keys { |key| header[key] }
      end
    end

    def rows
      @rows ||= book.sheets.first.simple_rows.lazy
    end

    private
      def book
        @book ||= Creek::Book.new @file, check_file_extension: false
      end
  end
end
