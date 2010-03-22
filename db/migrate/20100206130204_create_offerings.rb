# Copyright (C) 2010  Roberto Maestroni
#
# This file is part of Rcarpooling.
#
# Rcarpooling is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rcarpooling is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero Public License for more details.
#
# You should have received a copy of the GNU Affero Public License
# along with Rcarpooling.  If not, see <http://www.gnu.org/licenses/>.

class CreateOfferings < ActiveRecord::Migration
  def self.up
    create_table :offerings do |t|
      t.integer :departure_place_id
      t.integer :arrival_place_id
      t.datetime :departure_time
      t.datetime :expiry_time
      t.integer :length
      t.integer :travel_duration
      t.integer :offerer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offerings
  end
end
