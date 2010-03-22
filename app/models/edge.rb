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

class Edge < ActiveRecord::Base

  belongs_to :departure_place,
      :foreign_key => "departure_place_id",
      :class_name => "Place"


  belongs_to :arrival_place,
      :foreign_key => "arrival_place_id",
      :class_name => "Place"



  validates_presence_of :departure_place, :arrival_place


  validates_numericality_of :length, :only_integer => true, :greater_than => 0


  validates_numericality_of :travel_duration, :only_integer => true,
      :greater_than => 0


  validate :arrival_place_must_be_distinct_from_departure_place



  private


  def arrival_place_must_be_distinct_from_departure_place
    if departure_place and arrival_place and arrival_place == departure_place
      errors.add(:arrival_place, "must be distinct from departure place")
    end
  end

end
