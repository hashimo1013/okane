class CreateMoney < ActiveRecord::Migration[5.2]
  def change
    create_table :money do |t|
      t.integer :expenses
      t.timestamps
    end
  end
end
