class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should list users" do
    get users_url
    assert_response :success
    hari = users(:hari)
    mahesh = users(:mahesh)
    assert_match hari.name, response.body
    assert_match hari.email, response.body
    assert_match mahesh.name, response.body
    assert_match mahesh.email, response.body
  end

  test "should create users" do
    new_user_name = "Bodhish T"
    new_user_email = "bodhish@example.com"
    new_user_password = "password3"
    post users_url, params: { name: new_user_name, email: new_user_email, password: new_user_password }
    assert_response :success
    assert_equal User.count, 3
    new_user = User.find_by!(email: new_user_email)
    assert_equal new_user.password, new_user_password
    get users_url
    assert_match new_user_name, response.body
    assert_match new_user_email, response.body
  end

  test "should login users" do
    hari = users(:hari)
    post "/users/login", params: { email: hari.email, password: hari.password }
    assert_match "true", response.body

    post "/users/login", params: { email: hari.email, password: "incorrect_password" }
    assert_match "false", response.body

    post "/users/login", params: { email: "unknown@example.com", password: "doesnt_matter" }
    assert_match "false", response.body
  end
end
