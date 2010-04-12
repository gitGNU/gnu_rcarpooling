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

class OfferingTest < ActiveSupport::TestCase

  test "valid offering" do
    offering = Offering.new(
      :departure_place => places(:sede_di_via_ravasi),
      :arrival_place => places(:sede_di_via_dunant),
      :offerer => users(:donald_duck),
      :departure_time => 2.hours.from_now,
      :arrival_time => 2.hours.from_now + 20.minutes,
      :length => 4000,
      :expiry_time => 15.minutes.from_now,
      :seating_capacity => 4)
    assert offering.valid?
    assert offering.save
  end


  test "invalid without required fields" do
    offering = Offering.new
    assert !offering.valid?
    assert offering.errors.invalid?(:departure_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        offering.errors.on(:departure_place)
    assert offering.errors.invalid?(:arrival_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        offering.errors.on(:arrival_place)
    assert offering.errors.invalid?(:departure_time)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        offering.errors.on(:departure_time)
    assert offering.errors.invalid?(:arrival_time)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        offering.errors.on(:arrival_time)
    assert offering.errors.invalid?(:expiry_time)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        offering.errors.on(:expiry_time)
    assert offering.errors.invalid?(:length)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        offering.errors.on(:length)
    assert offering.errors.invalid?(:offerer)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        offering.errors.on(:offerer)
    assert offering.errors.invalid?(:seating_capacity)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        offering.errors.on(:seating_capacity)
  end


  test "length must be greater than 0" do
    offering = Offering.new
    offering.length = -1
    assert !offering.valid?
    assert offering.errors.invalid?(:length)
    assert_equal I18n.t('activerecord.errors.messages.greater_than',
                        :count => 0),
        offering.errors.on(:length)
  end


  test "arrival time must be later than departure time" do
    offering = Offering.new
    offering.departure_time = 1.hour.from_now
    offering.arrival_time = offering.departure_time
    assert ! offering.valid?
    assert offering.errors.invalid?(:arrival_time)
    assert_equal I18n.t("activerecord.errors.messages." +
                                       "offering.arrival_time_must_be_" +
                                      "later_than_departure_time"),
        offering.errors.on(:arrival_time)
  end


  test "seating capacity must be greater than 0" do
    offering = Offering.new
    offering.seating_capacity = 0
    assert ! offering.valid?
    assert offering.errors.invalid?(:seating_capacity)
    assert_equal I18n.t('activerecord.errors.messages.greater_than',
                        :count => 0), offering.errors.on(:seating_capacity)
  end


  test "departure time must be later than 10 minutes from now for a new offering" do
    offering = Offering.new
    offering.departure_time = (9.minutes + 59.seconds).from_now
    assert !offering.valid?
    assert offering.errors.invalid?(:departure_time)
    assert_equal I18n.t("activerecord.errors.messages." +
                                         "offering.departure_time_must_be_" +
                                        "later_than_10_minutes_from_now"),
        offering.errors.on(:departure_time)
    # for an old offering (already saved) don't matter
    old_offering = offerings(:donald_duck_offering_n_2_dep_in_the_past)
    old_offering.valid?
    assert !old_offering.errors.invalid?(:departure_time)
  end


  test "expiry time must be later than 5 minutes from now for a new offering" do
    offering = Offering.new
    offering.expiry_time = (4.minutes + 59.seconds).from_now
    assert ! offering.valid?
    assert offering.errors.invalid?(:expiry_time)
    assert_equal I18n.t("activerecord.errors.messages.offering." +
                                      "expiry_time_must_be_later_than_5_minutes_from_now"),
        offering.errors.on(:expiry_time)
    # for an old offering (already saved) don't matter
    old_offering = offerings(:donald_duck_offering_n_2_dep_in_the_past)
    old_offering.valid?
    assert !old_offering.errors.invalid?(:expiry_time)
  end


  test "expiry time must be earlier than or equal to departure time" do
    offering = Offering.new
    offering.departure_time = 1.hour.from_now
    offering.expiry_time = 2.hours.from_now
    assert !offering.valid?
    assert offering.errors.invalid?(:expiry_time)
    assert_equal I18n.t("activerecord.errors.messages." +
                                        "offering.expiry_time_must_be_" +
                                       "earlier_than_or_equal_to_" +
                                       "departure_time"),
        offering.errors.on(:expiry_time)
  end


  test "expiry time must be later than or equal to 2 hours before departure time" do
    offering = Offering.new
    offering.departure_time = 3.hours.from_now
    offering.expiry_time = offering.departure_time - (2.hours + 1.second)
    assert !offering.valid?
    assert offering.errors.invalid?(:expiry_time)
    assert_equal I18n.t("activerecord.errors.messages.offering." +
                                        "expiry_time_must_be_later_than_" +
                                       "or_equal_to_2_hours_before_departure_time"),
        offering.errors.on(:expiry_time)
  end


  test "arrival place must be distinct from departure place" do
    offering = Offering.new
    offering.departure_place = places(:sede_di_via_ravasi)
    offering.arrival_place = offering.departure_place
    assert ! offering.valid?
    assert offering.errors.invalid?(:arrival_place)
    assert_equal I18n.t("activerecord.errors.messages." +
                                          "offering.arrival_place_must_be_" +
                                         "distinct_from_departure_place"),
        offering.errors.on(:arrival_place)
  end


  test "travel duration is arrival time - departure time" do
    offering = Offering.new
    dep_time = 1.hour.from_now
    expected_duration = 10
    arr_time = dep_time + expected_duration.minutes
    offering.departure_time = dep_time
    offering.arrival_time = arr_time
    assert_equal expected_duration, offering.travel_duration
  end


  test "chilled?" do
    offering = Offering.new
    offering.departure_time = 2.hours.from_now
    assert offering.chilled?
    offering.departure_time = 2.hours.from_now + 1.minute
    assert ! offering.chilled?
  end

end
