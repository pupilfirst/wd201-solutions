require "date"
require "active_record"

class Todo < ActiveRecord::Base
  def overdue?
    due_date < Date.today
  end

  def due_today?
    due_date == Date.today
  end

  def due_later?
    due_date > Date.today
  end

  def self.overdue
    where("due_date < ?", Date.today)
  end

  def self.due_today
    where("due_date = ?", Date.today)
  end

  def self.due_later
    where("due_date > ?", Date.today)
  end

  def to_displayable_string
    status = completed ? "[x]" : "[ ]"
    date = due_today? ? nil : due_date
    "#{id}. #{status} #{todo_text} #{date}"
  end

  def self.show_list
    puts "My Todo-list\n\n"

    puts "Overdue"
    puts overdue.map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Today"
    puts due_today.map { |todo| todo.to_displayable_string }
    puts "\n\n"

    puts "Due Later"
    puts due_later.map { |todo| todo.to_displayable_string }
  end

  def self.add_task(task)
    create!(
      todo_text: task[:todo_text],
      due_date: Date.today + task[:due_in_days],
      completed: false,
    )
  end

  def self.mark_as_complete(id)
    todo = find(id)
    todo.completed = true
    todo.save!

    puts todo.to_displayable_string
  end
end
