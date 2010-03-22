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

class EdgeOnFootTest < ActiveSupport::TestCase

  test "static method find all adjacent by departure place" do
    places = EdgeOnFoot.find_all_adjacent_by_departure_place(places(:x1))
    assert_equal 2, places.size
    assert places.include?(places(:x2))
    assert places.include?(places(:x3))
  end


  test "static method find all adjacent by arrival place" do
    places = EdgeOnFoot.find_all_adjacent_by_arrival_place(places(:x1))
    assert_equal 2, places.size
    assert places.include?(places(:x2))
    assert places.include?(places(:x3))
  end


  test "find all adjacent by departure place with max length" do
    places = EdgeOnFoot.find_all_adjacent_by_departure_place(places(:x1),
                                                             400)
    assert_equal 2, places.size
    assert places.include?(places(:x2))
    assert places.include?(places(:x3))
    #
    places = EdgeOnFoot.find_all_adjacent_by_departure_place(places(:x1),
                                                             399)
    assert places.empty?
  end


  test "find all adjacent by arrival place with max length" do
    places = EdgeOnFoot.find_all_adjacent_by_arrival_place(places(:x1),
                                                           400)
    assert_equal 2, places.size
    assert places.include?(places(:x2))
    assert places.include?(places(:x3))
    #
    places = EdgeOnFoot.find_all_adjacent_by_arrival_place(places(:x1),
                                                           399)
    assert places.empty?
  end


end
