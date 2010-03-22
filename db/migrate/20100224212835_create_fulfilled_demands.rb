class CreateFulfilledDemands < ActiveRecord::Migration
  def self.up
    create_table :fulfilled_demands do |t|
      t.integer :demand_id

      t.timestamps
    end
  end

  def self.down
    drop_table :fulfilled_demands
  end
end
