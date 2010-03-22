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

class UsersControllerTest < ActionController::TestCase

  test "get a user" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :id => user.id
    assert_response :success
    assert_not_nil assigns(:user)
  end


  test "cannot get a user without credentials" do
    get :show, :id => users(:donald_duck).id
    assert_response :unauthorized
  end


  test "get a non-existent user" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :id => -1
    assert_response :not_found
  end


  test "can get only my data" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :id => users(:mickey_mouse).id
    assert_response :forbidden
  end


  test "get ME" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :me
    assert_response :temporary_redirect
    assert_redirected_to user
  end


  test "cannot get ME without credentials" do
    get :me
    assert_response :unauthorized
  end


end
