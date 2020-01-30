require 'byebug'
require 'csv'
require 'date'
require 'active_support'
require 'active_support/core_ext'

class CreditCSV
  attr_accessor :employer_credits

  def initialize
    @credit_files = Dir.glob('*Credit*.csv')
    @employer_credits = {}
  end

  def employer_id(record)
    record.fetch('Employer ID')
  end

  def remaining_balance(record)
    record.fetch('Remaining Balance').to_f
  end

  def process
    @credit_files.each do |file|
      CSV.foreach(file, headers: true) do |row|
        id = employer_id(row)
        @employer_credits[id] ||= 0
        @employer_credits[id] += remaining_balance(row)
      end
    end
  end
end

class CardCSV
  attr_accessor :employer_credits, :closed_cards

  def initialize(employer_credits)
    @employer_credits = employer_credits
    @card_files = Dir.glob('*CardsACH*.csv')
    @closed_cards = []
  end

  def employer_id(row)
    row.fetch('Employer ID')
  end

  def date_fulfilled(row)
    date_string = row.fetch('Date Fulfilled')
    return if date_string.blank?

    Date.strptime(date_string, '%m/%d/%Y')
  end

  def remaining_balance(row)
    row.fetch('Remaining Balance').to_f
  end

  def expired?(date)
    return if date.blank?

    (date >> 12) <= Date.current
  end

  def card_id(row)
    row.fetch('Card ID')
  end

  def process
    @card_files.each do |file|
      CSV.foreach(file, headers: true) do |row|
        next unless expired?(date_fulfilled(row))

        id = employer_id(row)
        balance = remaining_balance(row)
        @employer_credits[id] ||= 0
        @employer_credits[id] += balance
        @closed_cards << card_id(row) unless balance.zero?
      end
    end
  end
end

class EmployerCSV
  def initialize(employer_credits)
    @employer_credits = employer_credits
    @employer_files = Dir.glob('*Employer*.csv')
  end

  def starting_credit(record)
    record.fetch('Starting Credit', nil)
  end

  def employer_id(record)
    record.fetch('Employer ID')
  end

  def process
    @employer_files.each do |file|
      headers = File.readlines(file).first.chomp
      file_with_credits = File.open("#{file}_with_credits", 'w')
      file_with_credits << headers + ",Starting Credit\n"

      CSV.foreach(file, headers: true) do |row|
        break unless starting_credit(row).nil?

        id = employer_id(row)
        starting_credit = @employer_credits[id] || 0.0
        row['Starting Credit'] = starting_credit
        file_with_credits << row
      end

      file_with_credits.close
    end
  end
end

credits = CreditCSV.new
credits.process

cards = CardCSV.new(credits.employer_credits)
cards.process

employers = EmployerCSV.new(cards.employer_credits)
employers.process

puts cards.employer_credits

File.write('closed_cards.txt', cards.closed_cards.join("\n"))
