class Todo < ApplicationRecord
  validates :todo_text, presence: :true, length: { minimum: 2 }
  validates :due_date, presence: :true

  belongs_to :user

  def due_today?
    @due_date == Date.today
  end

  def self.overdue
    where("due_date < ? and completed = ?", Date.today, false)
  end

  def self.due_today
    where("due_date = ?", Date.today)
  end

  def self.due_later
    where("due_date > ?", Date.today)
  end

  def self.completed
    all.where(completed: true)
  end
end
