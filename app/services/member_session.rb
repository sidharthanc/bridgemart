class MemberSession
  include Enumerable

  def initialize(session)
    @session = session
    @session[:members] ||= []
  end

  def store(member)
    if include?(member)
      update member
    else
      add member
    end
  end

  def update(member)
    find(member).tap do |member_hash|
      member_hash['first_name'] = member.first_name
      member_hash['middle_name'] = member.middle_name
      member_hash['last_name'] = member.last_name
    end
  end

  def add(member)
    @session[:members] << {
      'id' => member.id,
      'first_name' => member.first_name,
      'middle_name' => member.middle_name,
      'last_name' => member.last_name
    }
  end

  def include?(member)
    find(member).present?
  end

  def valid_members(order)
    @session[:members].keep_if { |m| order.members.pluck(:id).include? m['id'] }
  end

  def find(member)
    @session[:members].detect { |m| m['id'] == member.id }
  end

  def each(&_block)
    @session[:members].each do |member_hash|
      yield MemberSession::Member.new(member_hash)
    end
  end

  class Member
    attr_reader :id, :first_name, :middle_name, :last_name

    def initialize(member_hash)
      @id = member_hash['id']
      @first_name = member_hash['first_name']
      @middle_name = member_hash['middle_name']
      @last_name = member_hash['last_name']
    end

    def to_s
      "#{last_name}, #{first_name}".tap do |name|
        name << " #{middle_name[0]}." if middle_name.present?
      end
    end
  end
end
