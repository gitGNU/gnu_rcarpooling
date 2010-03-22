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

class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :name
      t.string :city
      t.string :street
      t.string :civic_number
      t.float :latitude
      t.float :longitude
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
