class TodosController < ApplicationController
  # GET /todos
  def index
    @todos = current_user.todos
    render "index"
  end

  # POST /todos
  def create
    todo_text = params[:todo_text]
    due_date = Time.zone.parse(params[:due_date])

    todo = current_user.todos.new(
      todo_text: todo_text,
      due_date: due_date,
      completed: false,
    )

    if todo.save
      flash[:notice] = "A new to-do has been added."
      redirect_to todos_path
    else
      flash[:error] = "Encountered errors: #{todo.errors.full_messages.join(", ")}"
      redirect_to new_todo_path
    end
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
