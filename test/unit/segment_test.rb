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

class SegmentTest < ActiveSupport::TestCase

  test "valid segment" do
    segment = Segment.new( :order_number => 1,
                           :fulfilled_demand => fulfilled_demands(:fulfilled_demand_n_1))
    assert segment.valid?
    assert segment.save
  end


  test "invalid without required fields" do
    segment = Segment.new
    assert !segment.valid?
    assert segment.errors.invalid?(:order_number)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        segment.errors.on(:order_number)
    assert segment.errors.invalid?(:fulfilled_demand)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        segment.errors.on(:fulfilled_demand)
  end


  test "order number must be greater than 0" do
    segment = Segment.new(:order_number => -1)
    assert !segment.valid?
    assert segment.errors.invalid?(:order_number)
    assert_equal "must be greater than 0",segment.errors.on(:order_number)
  end
end
