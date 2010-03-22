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

require 'test_helper'

class FulfilledDemandFactoryTest < ActiveSupport::TestCase


  @@TIME = Time.now

  test "foot, car, foot" do
    demand = Demand.new
    used_offering = UsedOffering.new
    departure_place = Place.new
    car_departure_place = Place.new
    car_arrival_place = Place.new
    arrival_place = Place.new
    #
    factory = FulfilledDemandFactory.new(
      demand, used_offering,
      departure_place,
      @@TIME,
      0, 0,
      car_departure_place,
      car_arrival_place,
      arrival_place,
      @@TIME,
      0, 0)
    fulfilled_demand = factory.build_fulfilled_demand
    #
    assert_equal demand, fulfilled_demand.demand
    #
    assert_not_nil fulfilled_demand.first_segment_on_foot
    assert_not_nil fulfilled_demand.second_segment_on_foot
    assert_not_nil fulfilled_demand.segment_by_car
    #
    assert_equal 1, fulfilled_demand.first_segment_on_foot.order_number
    assert_equal 2, fulfilled_demand.segment_by_car.order_number
    assert_equal 3, fulfilled_demand.second_segment_on_foot.order_number
    #
    assert_equal departure_place,
        fulfilled_demand.first_segment_on_foot.departure_place
    assert_equal car_departure_place,
        fulfilled_demand.first_segment_on_foot.arrival_place
    assert_equal car_arrival_place,
        fulfilled_demand.second_segment_on_foot.departure_place
    assert_equal arrival_place,
        fulfilled_demand.second_segment_on_foot.arrival_place
  end


  test "foot, car" do
    demand = Demand.new
    used_offering = UsedOffering.new
    departure_place = Place.new
    car_departure_place = Place.new
    car_arrival_place = Place.new
    arrival_place = car_arrival_place
    #
    factory = FulfilledDemandFactory.new(
      demand, used_offering,
      departure_place,
      @@TIME,
      0, 0,
      car_departure_place,
      car_arrival_place,
      arrival_place,
      @@TIME,
      0, 0)
    fulfilled_demand = factory.build_fulfilled_demand
    #
    assert_equal demand, fulfilled_demand.demand
    #
    assert_not_nil fulfilled_demand.first_segment_on_foot
    assert_nil fulfilled_demand.second_segment_on_foot
    assert_not_nil fulfilled_demand.segment_by_car
    #
    assert_equal 1, fulfilled_demand.first_segment_on_foot.order_number
    assert_equal 2, fulfilled_demand.segment_by_car.order_number
    #
    assert_equal departure_place,
        fulfilled_demand.first_segment_on_foot.departure_place
    assert_equal car_departure_place,
        fulfilled_demand.first_segment_on_foot.arrival_place
  end


  test "car, foot" do
    demand = Demand.new
    used_offering = UsedOffering.new
    departure_place = Place.new
    car_departure_place = departure_place
    car_arrival_place = Place.new
    arrival_place = Place.new
    #
    factory = FulfilledDemandFactory.new(
      demand, used_offering,
      departure_place,
      @@TIME,
      0, 0,
      car_departure_place,
      car_arrival_place,
      arrival_place,
      @@TIME,
      0, 0)
    fulfilled_demand = factory.build_fulfilled_demand
    #
    assert_equal demand, fulfilled_demand.demand
    #
    assert_nil fulfilled_demand.first_segment_on_foot
    assert_not_nil fulfilled_demand.second_segment_on_foot
    assert_not_nil fulfilled_demand.segment_by_car
    #
    assert_equal 1, fulfilled_demand.segment_by_car.order_number
    assert_equal 2, fulfilled_demand.second_segment_on_foot.order_number
    #
    assert_equal car_arrival_place,
        fulfilled_demand.second_segment_on_foot.departure_place
    assert_equal arrival_place,
        fulfilled_demand.second_segment_on_foot.arrival_place
  end


  test "only car" do
    demand = Demand.new
    used_offering = UsedOffering.new
    departure_place = Place.new
    car_departure_place = departure_place
    car_arrival_place = Place.new
    arrival_place = car_arrival_place
    #
    factory = FulfilledDemandFactory.new(
      demand, used_offering,
      departure_place,
      @@TIME,
      0, 0,
      car_departure_place,
      car_arrival_place,
      arrival_place,
      @@TIME,
      0, 0)
    fulfilled_demand = factory.build_fulfilled_demand
    #
    assert_equal demand, fulfilled_demand.demand
    #
    assert_nil fulfilled_demand.first_segment_on_foot
    assert_nil fulfilled_demand.second_segment_on_foot
    assert_not_nil fulfilled_demand.segment_by_car
    #
    assert_equal 1, fulfilled_demand.segment_by_car.order_number
  end
end
