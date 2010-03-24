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

class EdgeTest < ActiveSupport::TestCase

  test "valid edge" do
    edge = Edge.new(:departure_place => places(:sede_di_via_ravasi),
                    :arrival_place => places(:sede_di_via_dunant),
                    :length => 3000,
                    :travel_duration => 15)
    assert edge.valid?
    assert edge.save
  end


  test "invalid without required fields" do
    edge = Edge.new
    assert !edge.valid?
    assert edge.errors.invalid?(:departure_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        edge.errors.on(:departure_place)
    assert edge.errors.invalid?(:arrival_place)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        edge.errors.on(:arrival_place)
    assert edge.errors.invalid?(:length)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        edge.errors.on(:length)
    assert edge.errors.invalid?(:travel_duration)
    assert_equal I18n.translate('activerecord.errors.messages.not_a_number'),
        edge.errors.on(:travel_duration)
  end


  test "arrival place must be distinct from departure place" do
    edge = Edge.new(:departure_place => places(:sede_di_via_ravasi),
                    :arrival_place => places(:sede_di_via_ravasi))
    assert !edge.valid?
    assert edge.errors.invalid?(:arrival_place)
    assert_equal I18n.t("activerecord.errors.messages.edge." +
                                        "arrival_place_must_be_distinct_" +
                                       "from_departure_place"),
        edge.errors.on(:arrival_place)
  end


  test "length must be greater than 0" do
    edge = Edge.new(:length => 0)
    assert !edge.valid?
    assert edge.errors.invalid?(:length)
    assert_equal I18n.t('activerecord.errors.messages.greater_than',
                        :count => 0), edge.errors.on(:length)
  end


  test "travel duration must be greater than 0" do
    edge = Edge.new(:travel_duration => 0)
    assert !edge.valid?
    assert edge.errors.invalid?(:travel_duration)
    assert_equal I18n.t('activerecord.errors.messages.greater_than',
                        :count => 0), edge.errors.on(:travel_duration)
  end

end
