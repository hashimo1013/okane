class AddUserToMoney < ActiveRecord::Migration[5.2]
  def change
    add_reference :money, :user, null: false, foreign_key: true
  end
end
