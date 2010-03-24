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

class UsedOfferingTest < ActiveSupport::TestCase

  test "create a valid used offering" do
    uo = UsedOffering.new
    uo.offering = offerings(:donald_duck_offering_n_1)
    uo.seating_capacity = uo.offering.seating_capacity - 1
    assert uo.valid?
    assert uo.save
  end


  test "invalid without required fields" do
    uo = UsedOffering.new
    assert !uo.valid?
    assert uo.errors.invalid?(:offering)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        uo.errors.on(:offering)
    assert uo.errors.invalid?(:seating_capacity)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        uo.errors.on(:seating_capacity)
  end


  test "seating capacity must be greater than or equal to 0" do
    uo = UsedOffering.new
    uo.seating_capacity = -1
    assert !uo.valid?
    assert uo.errors.invalid?(:seating_capacity)
    assert_equal I18n.t('activerecord.errors.messages.greater_than_or_equal_to',
                        :count => 0), uo.errors.on(:seating_capacity)
  end


  test "getters" do
    offering = offerings(:donald_duck_offering_n_1)
    uo = UsedOffering.new
    uo.offering = offering
    assert_equal offering.length, uo.length
    assert_equal offering.travel_duration, uo.travel_duration
    assert_equal offering.departure_place, uo.departure_place
    assert_equal offering.arrival_place, uo.arrival_place
    assert_equal offering.departure_time, uo.departure_time
    assert_equal (offering.departure_time + offering.travel_duration.minutes),
        uo.arrival_time
    assert_equal offering.offerer, uo.driver
    assert_equal offering.chilled?, uo.chilled?
  end


  test "grab seating" do
    offering = offerings(:donald_duck_offering_n_1)
    uo = UsedOffering.new(:offering => offering,
                          :seating_capacity => offering.seating_capacity)
    assert_difference 'uo.seating_capacity', -1 do
      uo.grab_seating!
    end
  end


  test "release seating" do
    offering = offerings(:donald_duck_offering_n_1)
    uo = UsedOffering.new(:offering => offering,
                          :seating_capacity => offering.seating_capacity)
    assert_difference 'uo.seating_capacity', 1 do
      uo.release_seating!
    end
  end

end
