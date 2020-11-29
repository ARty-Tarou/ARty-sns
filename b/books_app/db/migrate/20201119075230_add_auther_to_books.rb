class AddAutherToBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :auther, :string
  end
end
