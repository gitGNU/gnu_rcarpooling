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

class DemandTest < ActiveSupport::TestCase

  test "create a valid demand" do
    demand = Demand.new
    demand.suitor = users(:mickey_mouse)
    demand.departure_place = places(:sede_di_via_ravasi)
    demand.arrival_place = places(:sede_di_via_dunant)
    demand.earliest_departure_time = 3.hours.from_now
    demand.latest_arrival_time = 6.hours.from_now
    demand.expiry_time = 6.minutes.from_now
    assert demand.valid?
    assert demand.save
  end


  test "invalid without required fields" do
    demand = Demand.new
    assert !demand.valid?
    assert demand.errors.invalid?(:suitor)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        demand.errors.on(:suitor)
    assert demand.errors.invalid?(:earliest_departure_time)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        demand.errors.on(:earliest_departure_time)
    assert demand.errors.invalid?(:latest_arrival_time)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        demand.errors.on(:latest_arrival_time)
    assert demand.errors.invalid?(:expiry_time)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        demand.errors.on(:expiry_time)
    assert demand.errors.invalid?(:departure_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        demand.errors.on(:departure_place)
    assert demand.errors.invalid?(:arrival_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        demand.errors.on(:arrival_place)
  end


  test "latest arrival time must be later than earliest departure time" do
    demand = Demand.new
    demand.earliest_departure_time = 1.hour.from_now
    demand.latest_arrival_time = demand.earliest_departure_time
    assert ! demand.valid?
    assert demand.errors.invalid?(:latest_arrival_time)
    assert_equal I18n.t("activerecord.errors.messages.demand." +
                "latest_arrival_time_must_be_later_than_earliest_" +
                       "departure_time"),
        demand.errors.on(:latest_arrival_time)
  end


  test "earliest departure time must be later than 10 minutes from now for new demands" do
    demand = Demand.new
    demand.earliest_departure_time = 10.minutes.from_now
    assert ! demand.valid?
    assert demand.errors.invalid?(:earliest_departure_time)
    assert_equal I18n.t("activerecord.errors.messages.demand.earliest_departure_time_must_be_later_than_10_minutes_from_now"),
        demand.errors.on(:earliest_departure_time)
    # for already saved demands doesn't matter
    old_demand = demands(:mickey_mouse_demand_n_2_dep_in_past)
    assert old_demand.valid?
    assert !old_demand.errors.invalid?(:earliest_departure_time)
  end


  test "expiry time must be earlier than or equal to earliest departure time" do
    demand = Demand.new
    demand.earliest_departure_time = 1.hour.from_now
    demand.expiry_time = demand.earliest_departure_time + 1.second
    assert ! demand.valid?
    assert demand.errors.invalid?(:expiry_time)
    assert_equal I18n.t("activerecord.errors.messages.demand.expiry_time_must_be_" +
                        "earlier_than_or_equal_to_earliest_departure_time"),
        demand.errors.on(:expiry_time)
  end


  test "expiry time must be later than 5 minutes from now for new demands" do
    demand = Demand.new
    demand.expiry_time = 4.minutes.from_now
    assert !demand.valid?
    assert demand.errors.invalid?(:expiry_time)
    assert_equal I18n.t("activerecord.errors.messages.demand.expiry_time_" +
                        "must_be_later_than_5_minutes_from_now"),
        demand.errors.on(:expiry_time)
    # for already saved demands doesn't matter
    old_demand = demands(:mickey_mouse_demand_n_2_dep_in_past)
    assert old_demand.valid?
    assert !old_demand.errors.invalid?(:expiry_time)
  end


  test "arrival place must be distinct from departure place" do
    demand = Demand.new
    demand.departure_place = places(:sede_di_via_ravasi)
    demand.arrival_place = demand.departure_place
    assert !demand.valid?
    assert demand.errors.invalid?(:arrival_place)
    assert_equal I18n.t("activerecord.errors.messages.demand." +
                        "arrival_place_must_be_distinct_from_departure_place"),
                        demand.errors.on(:arrival_place)
  end


  test "expired demand is not deletable" do
    demand = demands(:mickey_mouse_demand_n_2_dep_in_past)
    assert demand.expired?
    assert ! demand.deletable?
  end


end
