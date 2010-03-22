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

class CreateDemands < ActiveRecord::Migration
  def self.up
    create_table :demands do |t|
      t.integer :suitor_id
      t.float :departure_latitude
      t.float :departure_longitude
      t.float :arrival_latitude
      t.float :arrival_longitude
      t.datetime :earliest_departure_time
      t.datetime :latest_arrival_time
      t.datetime :expiry_time

      t.timestamps
    end
  end

  def self.down
    drop_table :demands
  end
end
