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

class BlackListPassengersEntryTest < ActiveSupport::TestCase

  test "create a black list entry" do
    entry = BlackListPassengersEntry.new
    entry.user = users(:donald_duck)
    entry.passenger = users(:mickey_mouse)
    assert entry.valid?
    assert entry.save
  end


  test "invalid without required fields" do
    entry = BlackListPassengersEntry.new
    assert !entry.valid?
    assert entry.errors.invalid?(:user)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        entry.errors.on(:user)
    assert entry.errors.invalid?(:passenger)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        entry.errors.on(:passenger)
  end


  test "passenger must be distinct from user" do
    entry = BlackListPassengersEntry.new
    entry.user = users(:donald_duck)
    entry.passenger = users(:donald_duck)
    assert !entry.valid?
    assert entry.errors.invalid?(:passenger)
    assert_equal I18n.t("activerecord.errors.messages." +
                                    "black_list_passengers_entry." +
                                   "passenger_must_be_distinct_from_user"),
        entry.errors.on(:passenger)
  end


  test "invalid repeated items" do
    user = users(:donald_duck)
    passenger = users(:mickey_mouse)
    entry_1 = BlackListPassengersEntry.new(:user => user,
                                           :passenger => passenger)
    entry_1.save!
    #
    entry_2 = BlackListPassengersEntry.new(:user => user,
                                           :passenger => passenger)
    assert !entry_2.valid?
    assert entry_2.errors.invalid?(:passenger_id)
    assert_equal I18n.t('activerecord.errors.messages.taken'),
        entry_2.errors.on(:passenger_id)
    # but the same passenger for 2 different users is ok :)
    user_2 = users(:user_N)
    entry_3 = BlackListPassengersEntry.new(:user => user_2,
                                           :passenger => passenger)
    assert entry_3.save
  end

end
