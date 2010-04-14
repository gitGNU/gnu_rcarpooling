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

class AuthenticatorTest < ActiveSupport::TestCase

  test "valid user" do
    user = users(:donald_duck)
    authenticator = Authenticator.new(user.nick_name, user.password)
    assert_equal user.id, authenticator.authenticate
  end


  test "potential user" do
    pu = potential_users(:uncle_scrooge)
    authenticator = Authenticator.new(pu.account_name, pu.password)
    assert_equal -1, authenticator.authenticate
  end


  test "unknown user" do
    auth = Authenticator.new("foo", "bar")
    assert !auth.authenticate
  end

end
