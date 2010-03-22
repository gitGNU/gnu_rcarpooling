class CreateUsedOfferings < ActiveRecord::Migration
  def self.up
    create_table :used_offerings do |t|
      t.integer :offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :used_offerings
  end
end
