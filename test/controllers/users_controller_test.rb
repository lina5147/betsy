require "test_helper"

describe UsersController do
  describe 'login' do
    it 'can log in an existing user' do
      user = perform_login(users(:ada))

      must_respond_with :redirect
    end

    it 'can log in an new user' do
      new_user = User.new(uid: '1111', username: 'new_user', provider: 'github', image: 'some string', email: 'test@test.com')

      expect {
        logged_in_user = perform_login(new_user)
      }.must_change 'User.count', 1

      must_respond_with :redirect
    end

    it 'redirects to root path if given invalid user data' do
      # Arrange - invalid user (uid is nil)
      start_count = User.count

      user = User.new(uid: nil, username: 'new_user', provider: 'github', image: 'some string', email: 'test@test.com')

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      # send login request for that user
      get omniauth_callback_path(:github)

      must_redirect_to root_path

      # find the new user in the DB
      user = User.find_by(uid: user.uid, provider: user.provider)

      # Make sure the user is nil
      expect(user).must_be_nil

      # Since we can read the session, check that the user ID was set as expected
      expect(session[:user_id]).must_be_nil

      # Should *not* have created a new user
      expect(User.count).must_equal start_count
    end
  end

  describe 'logout' do
    it 'can logout an existing user' do
      perform_login()

      # before logging out
      expect {session[:user_id]}.wont_be_nil

      delete logout_path, params: {} # log out

      expect(session[:user_id]).must_be_nil
      expect(flash[:success]).must_equal "Successfully logged out!"
    end
  end

  describe 'current user page' do
    it 'can get the current user page when logged in' do
      perform_login()
      get current_user_path
      must_respond_with :success
    end

    it 'cannot get current user page if not logged in' do
      # not logged in
      get current_user_path

      must_respond_with :redirect
      must_redirect_to root_path
      expect(flash[:error]).must_equal "You must be logged in to do that"
    end
  end

  describe 'fulfillment' do
    it 'can get the fulfillment page when logged in' do
      perform_login()

      get current_user_fulfillment_path
      must_respond_with :success
    end

    it 'cannot get fulfillment page if not logged in' do
      # not logged in
      get current_user_fulfillment_path

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it 'can get fulfillment page if user has not cart/cartitems' do
      Cart.all.each do |cart|
        cart.destroy
      end

      Cartitem.all.each do |item|
        item.destroy
      end

      perform_login()

      get current_user_fulfillment_path
      must_respond_with :success
    end
  end
end
