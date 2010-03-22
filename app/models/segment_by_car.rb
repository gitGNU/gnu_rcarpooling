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

class SegmentByCar < Segment

  belongs_to :vehicle_offering,
      :foreign_key => "vehicle_offering_id",
      :class_name => "UsedOffering"


  validates_presence_of :vehicle_offering


  def departure_time
    vehicle_offering.departure_time
  end


  def arrival_time
    vehicle_offering.arrival_time
  end


  def departure_place
    vehicle_offering.departure_place
  end


  def arrival_place
    vehicle_offering.arrival_place
  end


  def length
    vehicle_offering.length
  end


  def travel_duration
    vehicle_offering.travel_duration
  end

end
