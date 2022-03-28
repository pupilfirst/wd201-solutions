class TodosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :update]

  # GET /todos
  def index
    render plain: Todo.order(:due_date).map { |todo| todo.to_pleasant_string }.join("\n")
  end

  # GET /todos/:id
  def show
    id = params[:id]
    todo = Todo.find(id)

    render plain: todo.to_pleasant_string
  end

  # POST /todos
  def create
    todo_text = params[:todo_text]
    due_date = Time.zone.parse(params[:due_date])

    new_todo = Todo.create!(
      todo_text: todo_text,
      due_date: due_date,
      completed: false,
    )

    render plain: "Hey, your new todo has been created with ID #{new_todo.id}"
  end

  # PATCH /todos/:id
  def update
    id = params[:id]
    completed = params[:completed]

    todo = Todo.find(id)
    todo.completed = completed
    todo.save!

    render plain: "Update todo completed status to #{completed}"
  end
end
