class AddNameAndUsernameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :username, :string, null: false, unique: true
    add_index :users, :username, unique: true
  end
end
