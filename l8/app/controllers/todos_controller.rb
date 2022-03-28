class TodosController < ApplicationController
  # GET /todos
  def index
    render "index"
  end

  # GET /todos/:id
  def show
    id = params[:id]

    @todo = Todo.find(id)
    render "todo"
  end

  # POST /todos
  def create
    todo_text = params[:todo_text]
    due_date = Time.zone.parse(params[:due_date])

    Todo.create!(
      todo_text: todo_text,
      due_date: due_date,
      completed: false,
    )

    redirect_to todos_path
  end

  # PATCH /todos/:id
  def update
    id = params[:id]
    completed = params[:completed]

    todo = Todo.find(id)
    todo.completed = completed
    todo.save!

    redirect_to todos_path
  end

  # DELETE /todos/:id
  def destroy
    id = params[:id]

    todo = Todo.find(id)
    todo.destroy!

    redirect_to todos_path
  end
end
