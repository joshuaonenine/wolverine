class CreateContentDetails < ActiveRecord::Migration
  def change
    create_table :content_details do |t|

      t.timestamps null: false
    end
  end
end
