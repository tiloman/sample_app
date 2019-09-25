require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

def setup
  ActionMailer::Base.deliveries.clear
  @user = users(:michael)
end

test 'password_resets' do
  get new_password_reset_path
  assert_template 'password_resets/new'
  post password_resets_path, params: { password_reset: {email: ''}}
  assert_not flash.empty?
  assert_template 'password_resets/new'
  post password_resets_path, params: {password_reset: {email: @user.email}}
  assert_not_equal @user.reset_digest, @user.reload.reset_digest
  assert_equal 1, ActionMailer::Base.deliveries.size
  assert_not flash.empty?
  assert_redirected_to root_url
  #Passwort reset form
  user = assigns(:user)
  get edit_password_reset_path(user.reset_token, email: "")
  assert_redirected_to root_url
  #inactive user
  user.toggle!(:activated)
  get edit_password_reset_path(user.reset_token, email: user.email)
  assert_redirected_to root_url
  user.toggle!(:activated)
  #right emial, wrong token
  get edit_password_reset_path('wrong token', email: user.email)
  assert_redirected_to root_url
  #alles richtig
  get edit_password_reset_path(user.reset_token, email: user.email)
  assert_template 'password_resets/edit'
  assert_select 'input[name=email][type=hidden][value=?]', user.email
  #invalid password
  patch password_reset_path(user.reset_token), params: {email: user.email, user: { password: 'sadsas', password_confirmation: 'asdoins'}}
  assert_select 'div#error_explanation'
  #leeres Passwort
  patch password_reset_path(user.reset_token), params: {email: user.email, user: { password: '', password_confirmation: ''}}
  assert_select 'div#error_explanation'
  #valid password & confirmation
  patch password_reset_path(user.reset_token), params: {email: user.email, user: { password: 'foobar', password_confirmation: 'foobar'}}
  user.reload
  assert_nil user.reset_digest
  assert is_logged_in?
  assert_not flash.empty?
  assert_redirected_to user
end

test 'passwort_expiration' do
  get new_password_reset_path
  post password_resets_path, params: {password_reset: {email: @user.email }}
  @user = assigns(:user)
  @user.update_attribute(:reset_sent_at, 3.hours.ago)
  patch password_reset_path(@user.reset_token), params: { email: @user.email, user: {password: 'foobar', password_confirmation: 'foobar'}}
  assert_response :redirect
  follow_redirect!
  assert_match /abgelaufen/i, response.body

end


end
