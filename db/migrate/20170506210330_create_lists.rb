class CreateLists < ActiveRecord::Migration[5.1]
  def change
    create_table :lists do |t|
      t.string :letter
      t.string :tax_reference
      t.string :list_type
      t.date :date_list

      t.timestamps
    end
  end
end
