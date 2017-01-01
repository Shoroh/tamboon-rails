ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Let's require all files in the Support folder
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

class ActionDispatch::IntegrationTest
  # If we don't need to test real Omise Service at all
  # we could turn the OmiseChargeMock here, for all tests:

  # def setup
  #   OmiseChargeMock.start
  # end
  #
  # def teardown
  #   OmiseChargeMock.stop
  # end
end

class ActiveSupport::TestCase
  fixtures :all

  private

  def t(*args)
    I18n.t(*args)
  end

  def sign_in_user(email, password)
    get new_user_session_path
    post_via_redirect user_session_path, user: {
      email: email,
      password: password
    }
  end

  def assert_follow_link(path)
    assert_select "a[href='#{path}']"
    get path
  end
end
