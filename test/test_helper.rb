ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'simplecov'
require "minitest/rails"
require "minitest/reporters"  # for Colorized output
#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)
SimpleCov.start do
  add_filter 'test/' # Tests should not be checked for coverage.
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors) # causes out of order output.

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def setup
    OmniAuth.config.test_mode = true
  end

  def mock_auth_hash(user)
    return {
        provider: user.provider,
        uid: user.uid,
        info: {
          email: user.email,
          nickname: user.username,
          name: user.name,
          image: user.image
        }
    }
  end

  def perform_login(user = nil)
    user ||= User.first
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

    get omniauth_callback_path(:github)
    user = User.find_by(uid: user.uid, username: user.username)

    expect(user).wont_be_nil
    expect(session[:user_id]).must_equal user.id
  end

end
