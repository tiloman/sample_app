require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

def setup
  @user = users(:michael)
end

test "Layout links" do
  get root_path
  assert_template 'static_pages/home'
  assert_select 'a[href=?]', root_path, count: 2
  assert_select 'a[href=?]', help_path
  assert_select 'a[href=?]', about_path
  assert_select 'a[href=?]', contact_path
  get contact_path
  assert_select 'title', full_title("Contact")

  get signup_path
  assert_select 'title', full_title('Registrieren')

  get about_path
  get help_path
  get login_path

  log_in_as(@user)
  get users_path
  get edit_user_path(@user)
  assert_select 'a[href=?]', logout_path

end



end
