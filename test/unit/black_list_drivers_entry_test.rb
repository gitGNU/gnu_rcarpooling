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

class BlackListDriversEntryTest < ActiveSupport::TestCase

  test "create an entry" do
    entry = BlackListDriversEntry.new
    entry.user = users(:mickey_mouse)
    entry.driver = users(:donald_duck)
    assert entry.valid?
    assert entry.save
  end


  test "invalid without required fields" do
    entry = BlackListDriversEntry.new
    assert !entry.valid?
    assert entry.errors.invalid?(:user)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        entry.errors.on(:user)
    assert entry.errors.invalid?(:driver)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        entry.errors.on(:driver)
  end


  test "driver must be distinct from user" do
    entry = BlackListDriversEntry.new
    entry.user = users(:mickey_mouse)
    entry.driver = users(:mickey_mouse)
    assert !entry.valid?
    assert entry.errors.invalid?(:driver)
    assert_equal "must be distinct from user",
        entry.errors.on(:driver)
  end

end
