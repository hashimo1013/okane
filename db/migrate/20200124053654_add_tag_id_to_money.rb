class AddTagIdToMoney < ActiveRecord::Migration[5.2]
  def change
    add_reference :money, :tag, null: false, foreign_key: true
  end
end
