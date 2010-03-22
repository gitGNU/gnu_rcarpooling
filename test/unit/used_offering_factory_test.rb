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

class UsedOfferingFactoryTest < ActiveSupport::TestCase

  test "factory does what I want" do
    offering = offerings(:donald_duck_offering_n_1)
    factory = UsedOfferingFactory.new(offering)
    uo = factory.build_used_offering
    assert_equal offering, uo.offering
    assert_equal offering.seating_capacity, uo.seating_capacity
  end

end
