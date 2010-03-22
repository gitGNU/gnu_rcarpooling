class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :edges do |t|
      t.string :type
      t.integer :departure_place_id
      t.integer :arrival_place_id
      t.integer :length
      t.integer :travel_duration

      t.timestamps
    end
  end

  def self.down
    drop_table :edges
  end
end
