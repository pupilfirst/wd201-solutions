class ImproveUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :name, :string
    remove_column :users, :password, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :password_digest, :string
  end
end
