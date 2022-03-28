class TodosControllerTest < ActionDispatch::IntegrationTest
  test "should list todos" do
    get todos_url
    assert_response :success
    assert_match todos(:incomplete).todo_text, response.body
    assert_match todos(:complete).todo_text, response.body
  end

  test "should show details of a todo" do
    incomplete_todo = todos(:incomplete)
    get todo_url(incomplete_todo.id)
    assert_response :success
    assert_match incomplete_todo.todo_text, response.body
    assert_no_match todos(:complete).todo_text, response.body
  end

  test "should create todos" do
    new_todo_text = "New todo"
    post todos_url, params: { todo_text: new_todo_text, due_date: 2.days.from_now.iso8601 }
    assert_response :success
    assert_equal Todo.count, 3
    get todos_url
    assert_match new_todo_text, response.body
  end

  test "should update todos" do
    incomplete_todo = todos(:incomplete)
    patch todo_url(incomplete_todo.id), params: { completed: true }
    assert_response :success
    assert_equal incomplete_todo.reload.completed, true

    completed_todo = todos(:complete)
    patch todo_url(completed_todo.id), params: { completed: false }
    assert_response :success
    assert_equal completed_todo.reload.completed, false
  end
end
