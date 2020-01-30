require 'byebug'
require 'csv'
require 'date'
require 'active_support'
require 'active_support/core_ext'

#   This script must be run in the app directory with the following command:
#   `bin/rails ruby runner update_credit_balances.rb`
#
#   The Employer*csv and Credits*csv files have to be in the same folder as well.

class CreditCSV
  attr_accessor :employer_credits

  def initialize
    @credit_files = Dir.glob('*Credit*.csv')
    @employer_credits = {}
  end

  def employer_id(record)
    [record.fetch('Employer ID'), record.fetch('Location ID')].without(nil, '').join('-')
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

class EmployerCSV
  def initialize(employer_credits)
    @employer_credits = employer_credits
    @employer_files = Dir.glob('*Employer*.csv')
  end

  def starting_credit(record)
    record.fetch('Starting Credit', nil)
  end

  def employer_id(record)
    [record.fetch('Employer ID'), record.fetch('Location ID')].without(nil, '').join('-')
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

def clean_up_credits(employer_credits)
  location_credits = employer_credits.select { |ec| ec.match /\d-\d/ }
  extra_credits = {}
  location_credits.each do |lc|
    empid = lc[0].split('-')[0]
    ec = employer_credits[empid]
    extra_credits[empid] = ec if ec
  end
  location_credits.merge(extra_credits)
end

def update_credits(credits)
  credits.each do |legid, amount|
    org = Organization.find_by legacy_identifier: legid
    if org
      if org.credits.count <= 1
        org.credits.first.update amount_cents: amount * 100
        puts "PASS: #{legid} updated to #{amount}"
      else
        puts "FAIL: #{legid} has too many Credits (#{org.credits.count})"
      end
    else
      "FAIL: #{legid} not found, amount to be applied #{amount}"
    end
  end
end

credits = CreditCSV.new
credits.process

employers = EmployerCSV.new(credits.employer_credits)
employers.process

credits = clean_up_credits(credits.employer_credits)

update_credits(credits)
