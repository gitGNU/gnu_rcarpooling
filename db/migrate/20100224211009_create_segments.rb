class CreateSegments < ActiveRecord::Migration
  def self.up
    create_table :segments do |t|
      t.string :type
      t.integer :order_number
      t.integer :departure_place_id
      t.integer :arrival_place_id
      t.datetime :departure_time
      t.integer :length
      t.integer :travel_duration
      t.integer :vehicle_offering_id
      t.integer :fulfilled_demand_id

      t.timestamps
    end
  end

  def self.down
    drop_table :segments
  end
end
