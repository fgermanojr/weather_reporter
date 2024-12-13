class CreateForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :forecasts do |t|
      t.string :zipcode, index: true
      t.text :result
      t.timestamps
    end
  end
end
