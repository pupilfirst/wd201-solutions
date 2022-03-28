class Todo < ApplicationRecord
  def to_pleasant_string
    is_completed = completed ? "[x]" : "[ ]"
    "#{id}. #{due_date.to_fs(:long)} #{todo_text} #{is_completed}"
  end
end
