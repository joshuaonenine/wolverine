class CreateRemarks < ActiveRecord::Migration
  def change
    create_table :remarks do |t|

      t.timestamps null: false
    end
  end
end
