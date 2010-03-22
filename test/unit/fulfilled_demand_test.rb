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

class FulfilledDemandTest < ActiveSupport::TestCase

  test "valid fulfilled demand" do
    f_demand = FulfilledDemand.new(:demand =>
                                    demands(:mickey_mouse_demand_n_3),
                                   :segment_by_car => SegmentByCar.new)
    assert f_demand.valid?
    assert f_demand.save
  end


  test "invalid without required fields" do
    f_demand = FulfilledDemand.new
    assert !f_demand.valid?
    assert f_demand.errors.invalid?(:demand)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        f_demand.errors.on(:demand)
    assert f_demand.errors.invalid?(:segment_by_car)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        f_demand.errors.on(:segment_by_car)
  end


  test "getters projected toward first segment on foot" do
    dummy_segment = DummyFootSegment.new(1, 2, Time.now, "ahahah", 12, 0)
    fd = FulfilledDemand.new
    fd.first_segment_on_foot = dummy_segment
    assert fd.has_initial_walk?
    assert !fd.has_final_walk?
    assert_equal dummy_segment.departure_place, fd.departure_place
    assert_equal dummy_segment.departure_time, fd.departure_time
    assert_equal dummy_segment.length, fd.initial_walk_length
    assert_equal dummy_segment.travel_duration, fd.initial_walk_duration
  end


  test "getters projected toward second segment on foot" do
    dummy_segment = DummyFootSegment.new(1, 3, Time.now, "time :)", 12, 0)
    fd = FulfilledDemand.new
    fd.second_segment_on_foot = dummy_segment
    assert !fd.has_initial_walk?
    assert fd.has_final_walk?
    assert_equal dummy_segment.arrival_place, fd.arrival_place
    assert_equal dummy_segment.arrival_time, fd.arrival_time
    assert_equal dummy_segment.length, fd.final_walk_length
    assert_equal dummy_segment.travel_duration, fd.final_walk_duration
  end


  test "some getters in specific cases" do
    fd = FulfilledDemand.new
    assert !fd.has_initial_walk?
    assert !fd.has_final_walk?
    assert_equal 0, fd.initial_walk_length
    assert_equal 0, fd.initial_walk_duration
    assert_equal 0, fd.final_walk_length
    assert_equal 0, fd.final_walk_duration
  end


  test "getters projected toward segment by car" do
    dummy_car_segment = DummyCarSegment.new("bli", "blu", Time.now, 123,
                                            2, 12345)
    fd = FulfilledDemand.new
    fd.segment_by_car = dummy_car_segment
    assert_equal dummy_car_segment.departure_place, fd.car_departure_place
    assert_equal dummy_car_segment.arrival_place, fd.car_arrival_place
    assert_equal dummy_car_segment.departure_time, fd.car_departure_time
    assert_equal dummy_car_segment.length, fd.car_length
    assert_equal dummy_car_segment.travel_duration, fd.car_travel_duration
    #
    assert_equal dummy_car_segment.departure_place, fd.departure_place
    assert_equal dummy_car_segment.arrival_place, fd.arrival_place
    assert_equal dummy_car_segment.departure_time, fd.departure_time
    assert_equal dummy_car_segment.arrival_time, fd.arrival_time
  end


  test "static method find all fulfilled by a used offering" do
    used_offering = used_offerings(:donald_duck_offering_n_1_used)
    expected_fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_2)
    result = FulfilledDemand.find_all_fulfilled_by_a_used_offering(
      used_offering)
    #
    assert result.include?(expected_fulfilled_demand)
    assert_equal 1, result.size
    assert result[0].reload
    assert result[0].save
  end


  private


  class DummyFootSegment < SegmentOnFoot

    def initialize(departure_place, arrival_place, departure_time,
                   arrival_time,
                   length, travel_duration)
      @departure_place = departure_place; @arrival_place = arrival_place
      @departure_time = departure_time; @length = length
      @travel_duration = travel_duration
      @arrival_time = arrival_time
    end


    attr_reader :departure_place, :arrival_place, :departure_time, :length,
        :travel_duration, :arrival_time

  end # class


  class DummyCarSegment < SegmentByCar

    def initialize(departure_place, arrival_place, departure_time,
                   arrival_time,
                   length, travel_duration)
      @departure_place = departure_place; @arrival_place = arrival_place
      @departure_time = departure_time; @length = length
      @travel_duration = travel_duration
      @arrival_time = arrival_time
    end


    attr_reader :departure_place, :arrival_place, :departure_time, :length,
        :travel_duration, :arrival_time

  end # class


end
