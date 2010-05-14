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

class FulfilledDemand < ActiveRecord::Base

  belongs_to :demand


  has_one :first_segment_on_foot,
      :foreign_key => "fulfilled_demand_id",
      :class_name => "SegmentOnFoot",
      :conditions => "order_number = 1",
      :dependent => :destroy


  has_one :second_segment_on_foot,
      :foreign_key => "fulfilled_demand_id",
      :class_name => "SegmentOnFoot",
      :conditions => "order_number = 2 or order_number = 3",
      :dependent => :destroy


  has_one :segment_by_car,
      :foreign_key => "fulfilled_demand_id",
      :class_name => "SegmentByCar",
      :dependent => :destroy


  validates_presence_of :demand, :segment_by_car


  def self.find_all_fulfilled_by_a_used_offering(used_offering)
    self.find_by_sql("select fulfilled_demands.* from " +
                  "fulfilled_demands, segments where " +
                  "fulfilled_demands.id = segments.fulfilled_demand_id " +
                  "and segments.type = 'SegmentByCar' " +
                  "and vehicle_offering_id = #{used_offering.id}")
  end


  def suitor
    demand.suitor
  end


  def guaranteed?
    used_offering.chilled? # it is guaranteed if used_offering is chilled
  end


  def guaranteed_since
    used_offering.chilled_since
  end


  def chilled?
    Time.now >= chilled_since
  end


  def deletable?
    !chilled?
  end


  def chilled_since
    used_offering.expiry_time - 1.minute
  end


  def used_offering
    vehicle_offering
  end


  def vehicle_offering
    segment_by_car.vehicle_offering
  end


  def has_initial_walk?
    first_segment_on_foot && true
  end


  def has_final_walk?
    second_segment_on_foot && true
  end


  def departure_place
    if has_initial_walk?
      first_segment_on_foot.departure_place
    else
      car_departure_place
    end
  end


  def arrival_place
    if has_final_walk?
      second_segment_on_foot.arrival_place
    else
      car_arrival_place
    end
  end


  def departure_time
    if has_initial_walk?
      first_segment_on_foot.departure_time
    else
      car_departure_time
    end
  end


  def arrival_time
    if has_final_walk?
      second_segment_on_foot.arrival_time
    else
      car_arrival_time
    end
  end


  def car_departure_place
    segment_by_car.departure_place
  end


  def car_arrival_place
    segment_by_car.arrival_place
  end


  def car_departure_time
    segment_by_car.departure_time
  end


  def car_arrival_time
    segment_by_car.arrival_time
  end


  def car_travel_duration
    segment_by_car.travel_duration
  end


  def car_length
    segment_by_car.length
  end


  def initial_walk_duration
    (has_initial_walk? && first_segment_on_foot.travel_duration) || 0
  end


  def initial_walk_length
    (has_initial_walk? && first_segment_on_foot.length) || 0
  end


  def final_walk_duration
    (has_final_walk? && second_segment_on_foot.travel_duration) || 0
  end


  def final_walk_length
    (has_final_walk? && second_segment_on_foot.length) || 0
  end


  def driver
    vehicle_offering.driver
  end


  def vehicle_registration_plate
    driver.shows_vehicle_registration_plate? &&
        driver.vehicle_registration_plate
  end


  def demand_notifications
    demand.demand_notifications
  end

end
