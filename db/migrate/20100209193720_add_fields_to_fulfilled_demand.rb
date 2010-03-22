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

class AddFieldsToFulfilledDemand < ActiveRecord::Migration
  def self.up
    add_column :fulfilled_demands, :first_segment_departure_time, :datetime
    add_column :fulfilled_demands, :first_segment_travel_duration, :integer
    add_column :fulfilled_demands, :first_segment_length, :integer
    add_column :fulfilled_demands, :second_segment_departure_time, :datetime
    add_column :fulfilled_demands, :second_segment_travel_duration, :integer
    add_column :fulfilled_demands, :second_segment_length, :integer
  end

  def self.down
    remove_column :fulfilled_demands, :first_segment_departure_time
    remove_column :fulfilled_demands, :first_segment_travel_duration
    remove_column :fulfilled_demands, :first_segment_length
    remove_column :fulfilled_demands, :second_segment_departure_time
    remove_column :fulfilled_demands, :second_segment_travel_duration
    remove_column :fulfilled_demands, :second_segment_length
  end
end
