require 'csv'

MASTERCARD = 'MasterCard'.freeze
WALMART = "Walmart/Sam's".freeze

class Card < Importer
  def initialize(filepath, dryrun: false)
    super
    @bridge_vision = ProductCategory.find_by(name: 'Eye Exam')
    @bridge_safety = ProductCategory.find_by(name: 'Safety Eyewear')
    @bridge_fashion = ProductCategory.find_by(name: 'Fashion Eyewear')

    raise StandardError, 'The database must first be seeded with Division/Product Category records' if !@bridge_vision || !@bridge_safety || !@bridge_fashion

    build_legacy_product_categories
  end

  private
    def build_legacy_product_categories
      @bridge_vision = build_legacy_product_category @bridge_vision
      @bridge_safety = build_legacy_product_category @bridge_safety
      @bridge_fashion = build_legacy_product_category @bridge_fashion
    end

    def build_legacy_product_category(product_category)
      legacy_name = product_category.name + ' Legacy'
      pc = ProductCategory.find_by(name: legacy_name)
      return pc if pc

      new_product_category = product_category.dup
      new_product_category.name = legacy_name
      new_product_category.card_type = :legacy
      new_product_category.hidden = :hidden
      new_product_category.save!
      new_product_category
    end

    def create_schema_records(record)
      @record = record
      find_or_create_member
      @code = create_code
    end

    def order
      Order.find_by! legacy_identifier: invoice_legacy_identifier
    end

    def invoice_legacy_identifier
      @record.fetch('Invoice ID')
    end

    def product_category
      case @record.fetch('Rail Type')
      when MASTERCARD
        @bridge_vision
      when WALMART
        @bridge_safety
      else
        @bridge_fashion
      end
    end

    def plan_product_category
      @plan_product_category = PlanProductCategory.find_or_initialize_by(
        plan_id: order.plan_id,
        product_category_id: product_category.id,
        budget_cents: card_amount
      )
      @plan_product_category.save!
      @plan_product_category
    end

    def find_or_create_member
      first_name, last_name = member_name
      @member = Member.find_by email: member_email, first_name: first_name, last_name: last_name

      if @member
        log_exception RuntimeError.new('Member email reused'), @record
        return
      end

      @member = Member.create!(member_params)
    end

    def member_name
      full_name = @record.fetch('Employee / Member')
      first_name, last_name = full_name.split if full_name.present?

      first_name ||= 'UNKNOWN'
      last_name ||= 'UNKNOWN'

      [first_name, last_name]
    end

    def member_params
      first_name, last_name = member_name

      {
        first_name: first_name,
        last_name: last_name,
        email: member_email,
        order_id: order.id
      }
    end

    def member_email
      @record.fetch('Email Address')&.downcase
    end

    def create_code
      code = Code.new code_params
      code.save!
    end

    def today_if_deactivated
      Time.current if @record.fetch('Inactive') =~ /true/i
    end

    def convert_to_date(string)
      string.blank? ? Date.current : Date.strptime(string, '%m/%d/%Y')
    end

    def code_params
      {
        limit_cents: card_amount,
        legacy_identifier: @record.fetch('Card ID'),
        deactivated_at: today_if_deactivated,
        created_at: convert_to_date(@record.fetch('Date Assigned')),
        external_id: clean_external_id,
        member_id: @member.id,
        plan_product_category_id: plan_product_category.id,
        balance_cents: remaining_balance
      }
    end

    def card_amount
      @record.fetch('Card Amount').to_f * 100
    end

    def remaining_balance
      @record.fetch('Remaining Balance').to_f * 100
    end

    def clean_external_id
      @record.fetch('Card Number (Export)')&.gsub(/^'/, '')
    end
end
