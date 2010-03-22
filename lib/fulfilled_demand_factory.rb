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

class FulfilledDemandFactory


  def initialize(demand, used_offering,
                 departure_place,
                 first_walk_departure_time,
                 first_walk_duration, first_walk_length,
                 car_departure_place,
                 car_arrival_place,
                 arrival_place,
                 second_walk_departure_time,
                 second_walk_duration, second_walk_length)
    @demand = demand
    @used_offering = used_offering
    @departure_place = departure_place
    @first_walk_departure_time = first_walk_departure_time
    @first_walk_duration = first_walk_duration
    @first_walk_length = first_walk_length
    @car_departure_place = car_departure_place
    @car_arrival_place = car_arrival_place
    @arrival_place = arrival_place
    @second_walk_departure_time = second_walk_departure_time
    @second_walk_duration = second_walk_duration
    @second_walk_length = second_walk_length
  end


  def build_fulfilled_demand
    fd = FulfilledDemand.new
    first_segment_on_foot = nil
    second_segment_on_foot = nil
    if @departure_place != @car_departure_place
      first_segment_on_foot = SegmentOnFoot.new(
        :departure_place => @departure_place,
        :arrival_place => @car_departure_place,
        :departure_time => @first_walk_departure_time,
        :travel_duration => @first_walk_duration,
        :length => @first_walk_length,
        :order_number => 1,
        :fulfilled_demand => fd)
    end
    segment_by_car = SegmentByCar.new(
      :fulfilled_demand => fd,
      :vehicle_offering => @used_offering)
    segment_by_car.order_number = (first_segment_on_foot && 2) || 1
    if @arrival_place != @car_arrival_place
      second_segment_on_foot = SegmentOnFoot.new(
        :departure_place => @car_arrival_place,
        :arrival_place => @arrival_place,
        :departure_time => @second_walk_departure_time,
        :travel_duration => @second_walk_duration,
        :length => @second_walk_length,
        :order_number => segment_by_car.order_number + 1,
        :fulfilled_demand => fd)
    end
    fd.first_segment_on_foot = first_segment_on_foot
    fd.segment_by_car = segment_by_car
    fd.second_segment_on_foot = second_segment_on_foot
    fd.demand = @demand
    fd
  end

end
