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

class SegmentOnFootTest < ActiveSupport::TestCase

  test "valid segment on foot" do
    f_seg = SegmentOnFoot.new( :order_number => 1,
                               :fulfilled_demand => fulfilled_demands(:fulfilled_demand_n_1),
                               :departure_place => places(:sede_di_via_ravasi),
                               :arrival_place => places(:sede_di_via_dunant),
                               :departure_time => 10.minutes.from_now,
                               :length => 2000,
                               :travel_duration => 25)
    assert f_seg.valid?
    assert f_seg.save
  end


  test "invalid without required fields" do
    f_seg = SegmentOnFoot.new
    assert !f_seg.valid?
    assert f_seg.errors.invalid?(:departure_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        f_seg.errors.on(:departure_place)
    assert f_seg.errors.invalid?(:arrival_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        f_seg.errors.on(:arrival_place)
    assert f_seg.errors.invalid?(:departure_time)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        f_seg.errors.on(:departure_time)
    assert f_seg.errors.invalid?(:length)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        f_seg.errors.on(:length)
    assert f_seg.errors.invalid?(:travel_duration)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        f_seg.errors.on(:travel_duration)
  end


  test "departure place and arrival place must be distinct" do
    f_seg = SegmentOnFoot.new
    f_seg.departure_place = places(:sede_di_via_ravasi)
    f_seg.arrival_place = places(:sede_di_via_ravasi)
    assert ! f_seg.valid?
    assert f_seg.errors.invalid?(:arrival_place)
    assert_equal I18n.t("activerecord.errors.messages." +
                                        "segment_on_foot.arrival_place_" +
                                       "must_be_distinct_from_departure_place"),
        f_seg.errors.on(:arrival_place)
  end


  test "length must be greater than 0" do
    f_seg = SegmentOnFoot.new
    f_seg.length = 0
    assert ! f_seg.valid?
    assert f_seg.errors.invalid?(:length)
    assert_equal I18n.t('activerecord.errors.messages.greater_than',
                        :count => 0), f_seg.errors.on(:length)
  end


  test "travel duration must be greater than 0" do
    f_seg = SegmentOnFoot.new
    f_seg.travel_duration = 0
    assert ! f_seg.valid?
    assert f_seg.errors.invalid?(:travel_duration)
    assert_equal I18n.t("activerecord.errors.messages.greater_than",
                        :count => 0), f_seg.errors.on(:travel_duration)
  end

end
