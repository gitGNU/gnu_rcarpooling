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

class NotificationsControllerTest < ActionController::TestCase

  # GET /users/:user_id/notifications

  test "get index" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :index, :user_id => user.id
    assert_response :success
    assert_not_nil assigns(:notifications)
  end


  test "cannot get index without credentials" do
    get :index, :user_id => users(:donald_duck).id
    assert_response :unauthorized
  end


  test "cannot get index of someone's other" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :index, :user_id => users(:donald_duck).id
    assert_response :forbidden
  end


  test "get index not found with wrong user id" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :index, :user_id => -1
    assert_response :not_found
  end


  # GET /users/:user_id/notifications/:id

  test "get show" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :user_id => user.id, :id => notifications(:dd1)
    assert_response :success
    assert_not_nil assigns(:notification)
    #
    n = assigns(:notification)
    assert n.seen?
  end


  test "cannot get show without credentials" do
    get :show, :user_id => users(:donald_duck).id,
        :id => notifications(:dd1).id
    assert_response :unauthorized
  end


  test "cannot get show of someone's other" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :user_id => users(:donald_duck).id,
        :id => notifications(:dd1).id
    assert_response :forbidden
  end


  test "get show not found with wrong id" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :user_id => user.id, :id => -1
    assert_response :not_found
  end


  test "get show not found with wrong user id" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :user_id => -1, :id => notifications(:dd1).id
    assert_response :not_found
  end

end
