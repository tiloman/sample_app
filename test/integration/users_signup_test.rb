require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: { user: {name: "",email: "user@invalid", password: "foo", password_confirmation: "bar"}}
    end
    assert_template "users/new"
    assert_select '#error_explanation'
    assert_select '.alert'
    #assert_select 'form[action="/signup"]' funktioniert nicht mehr seit Listing 10.5

  end

  test 'valid user data' do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: {name: "Test Tester",email: "test@test.de", password: "foobar", password_confirmation: "foobar"}}
    end
    follow_redirect!
    assert_template "users/show"
    assert_not flash.empty?
    assert_select ".alert-success"
    assert is_logged_in?

  end





end
