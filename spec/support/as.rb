# Logs the user in, in any context. Usage:
#
# describe 'Whatever' do
#   as { users(:test) }
# end

shared_context 'as' do |proc|
  before do
    user = instance_eval(&proc)
    login_as user

    if request&.env
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['HTTP_AUTHORIZATION'] = "Token token=#{user.authentication_token}, id=#{user.id}"
    end
  end
end

def as(&block)
  include_context 'as', block
end
