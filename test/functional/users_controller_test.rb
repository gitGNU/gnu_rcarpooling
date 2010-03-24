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


  test "user xml contents" do
    user = users(:donald_duck)
    user.drivers_in_black_list << users(:mickey_mouse)
    user.passengers_in_black_list << users(:mickey_mouse)
    user.save!
    set_authorization_header(user.nick_name, user.password)
    get :show, :id => user.id
    assert_response :success
    # testing response content
    assert_select "user:root[id=#{user.id}][href=#{user_url(user)}]" do
      assert_select "first_name", user.first_name
      assert_select "last_name", user.last_name
      assert_select "sex", user.sex
      assert_select "nick_name", user.nick_name
      assert_select "email", user.email
      assert_select "lang", user.lang
      assert_select "max_foot_length", user.max_foot_length.to_s
      # black list
      assert_select "black_list" do
        user.drivers_in_black_list.each do |driver|
          assert_select "user[id=#{driver.id}]" +
              "[href=#{user_url(driver)}][rel=driver]" do
            assert_select "first_name", driver.first_name
            assert_select "last_name", driver.last_name
            assert_select "nick_name", driver.nick_name
          end
        end # loop on drivers
        user.passengers_in_black_list.each do |pass|
          assert_select "user[id=#{pass.id}]" +
              "[href=#{user_url(pass)}][rel=passenger]" do
            assert_select "first_name", pass.first_name
            assert_select "last_name", pass.last_name
            assert_select "nick_name", pass.nick_name
          end
        end # loop on passengers
      end
    end
  end


end
