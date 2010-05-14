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

class PotentialUserTest < ActiveSupport::TestCase


  test "valid potential user" do
    pu = PotentialUser.new :account_name => "foo",
        :password => "bar"
    assert pu.valid?
    assert pu.save
  end


  test "invalid with required fields" do
    pu = PotentialUser.new
    assert !pu.valid?
    assert pu.errors.invalid?(:account_name)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        pu.errors.on(:account_name)
    assert pu.errors.invalid?(:password)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        pu.errors.on(:password)
  end


  test "static method authenticate" do
    pu = potential_users(:uncle_scrooge)
    assert_equal pu.id, PotentialUser.authenticate(pu.account_name,
                                                   pu.password)
    #
    assert !PotentialUser.authenticate("foo", "bar")
  end


  test "set password" do
    pu = PotentialUser.new
    #
    pu.password = ""
    assert_nil pu.hashed_password
    assert_nil pu.salt
    #
    password = "this is a password"
    pu.password = password
    assert_nil pu.password # password is a field used only for tests
    assert_equal User.encrypted_password(password, pu.salt),
        pu.hashed_password
  end


end
