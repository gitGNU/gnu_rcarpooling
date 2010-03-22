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

class RemoveGeoLocationsFromDemand < ActiveRecord::Migration
  def self.up
    remove_column :demands, :departure_latitude
    remove_column :demands, :departure_longitude
    remove_column :demands, :arrival_latitude
    remove_column :demands, :arrival_longitude
  end

  def self.down
    add_column :demands, :departure_latitude, :float
    add_column :demands, :departure_longitude, :float
    add_column :demands, :arrival_latitude, :float
    add_column :demands, :arrival_longitude, :float
  end
end
