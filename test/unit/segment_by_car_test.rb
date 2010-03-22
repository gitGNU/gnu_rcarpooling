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

class SegmentByCarTest < ActiveSupport::TestCase

  test "valid segment by car" do
    car_seg = SegmentByCar.new(:order_number => 1,
                               :fulfilled_demand => fulfilled_demands(:fulfilled_demand_n_1),
                               :vehicle_offering => used_offerings(:donald_duck_offering_n_1_used))
    assert car_seg.valid?
    assert car_seg.save
  end


  test "invalid without required fields" do
    car_seg = SegmentByCar.new
    assert !car_seg.valid?
    assert car_seg.errors.invalid?(:vehicle_offering)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        car_seg.errors.on(:vehicle_offering)
  end


  test "getters projected toward used offering" do
    dummy_uo = DummyUsedOffering.new(12345, "bla", "bal", 123, "arrival time", 34,
                                     "qwerty")
    seg_car = SegmentByCar.new(:vehicle_offering => dummy_uo)
    assert_equal dummy_uo.departure_place, seg_car.departure_place
    assert_equal dummy_uo.arrival_place, seg_car.arrival_place
    assert_equal dummy_uo.departure_time, seg_car.departure_time
    assert_equal dummy_uo.arrival_time, seg_car.arrival_time
    assert_equal dummy_uo.length, seg_car.length
    assert_equal dummy_uo.travel_duration, seg_car.travel_duration
  end


  private


  class DummyUsedOffering < UsedOffering

    def initialize(id, departure_place, arrival_place, departure_time, arrival_time,
                   length, travel_duration)
      @departure_place = departure_place; @arrival_place = arrival_place
      @departure_time = departure_time; @arrival_time = arrival_time
      @length = length; @travel_duration = travel_duration
      @id = id
    end


    attr_reader :departure_place, :arrival_place, :departure_time, :arrival_time,
        :length, :travel_duration, :id

  end # class


end
