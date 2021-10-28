require "./connect_db.rb"

connect_db!

ActiveRecord::Migration.drop_table :todos if (ActiveRecord::Base.connection.table_exists? :todos)

ActiveRecord::Migration.create_table(:todos) do |t|
  t.column :todo_text, :text
  t.column :due_date, :date
  t.column :completed, :bool
end
