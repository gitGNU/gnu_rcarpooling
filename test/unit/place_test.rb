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

class PlaceTest < ActiveSupport::TestCase

  test "invalid without required fields" do
    place = Place.new
    assert ! place.valid?
    assert place.errors.invalid?(:latitude)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        place.errors.on(:latitude)
    assert place.errors.invalid?(:longitude)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        place.errors.on(:longitude)
    assert place.errors.invalid?(:name)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        place.errors.on(:name)
  end


  test "valid place" do
    place = Place.new(:name => "place's name",
                      :latitude => 90.0,
                      :longitude => 90.0)
    assert place.valid?
    assert place.save
  end
end
