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

class UnwelcomeDriversControllerTest < ActionController::TestCase


  def setup
    AuthenticatorFactory.set_factory(AuthenticatorFactoryMock.new)
  end


  def tear_down
    AuthenticatorFactory.clear_factory
  end


  test "get" do
    entry = black_list_drivers_entries(:one)
    set_authorization_header(entry.user.nick_name, entry.user.password)
    get :show, :user_id => entry.user.id, :id => entry.id
    assert_response :success
    assert_not_nil assigns(:unwelcome_driver)
    up = assigns(:unwelcome_driver)
    # testing response content
    assert_select "unwelcome_driver:root[id=#{up.id}]" +
        "[href=#{user_unwelcome_driver_url(:user_id => up.user.id,
                                              :id => up.id)}]" do
      assert_select "user[id=#{up.driver.id}][href=#{user_url(
        up.driver)}]" do
        assert_select "first_name", up.driver.first_name
        assert_select "last_name", up.driver.last_name
        assert_select "nick_name", up.driver.nick_name
      end
    end
  end


  test "can get only XML" do
    entry = black_list_drivers_entries(:one)
    set_authorization_header(entry.user.nick_name, entry.user.password)
    get :show, :format => "html", :user_id => entry.user.id,
        :id => entry.id
    assert_response :not_acceptable
  end


  test "cannot get without credentials" do
    entry = black_list_drivers_entries(:one)
    get :show, :user_id => entry.user.id, :id => entry.id
    assert_response :unauthorized
  end


  test "cannot get someone other's" do
    entry = black_list_drivers_entries(:one)
    u = users(:donald_duck)
    set_authorization_header(u.nick_name, u.password)
    get :show, :user_id => entry.user.id, :id => entry.id
    assert_response :forbidden
  end


  test "get with wrong user id" do
    entry = black_list_drivers_entries(:one)
    set_authorization_header(entry.user.nick_name, entry.user.password)
    get :show, :user_id => -1, :id => entry.id
    assert_response :not_found
  end


  test "get with wrong id" do
    entry = black_list_drivers_entries(:one)
    set_authorization_header(entry.user.nick_name, entry.user.password)
    get :show, :user_id => entry.user.id, :id => -1
    assert_response :not_found
  end


  # POST


  test "add a driver to black list" do
    user = users(:donald_duck)
    driver = users(:mickey_mouse)
    #
    assert !user.drivers_in_black_list.include?(driver)
    #
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 1) do
      post :create, :user_id => user.id,
          :unwelcome_driver => { :id => driver.id }
    end
    assert_response :created
    assert_not_nil assigns(:unwelcome_driver)
    #
    assert user.drivers_in_black_list.include?(driver)
    # testing response content
    up = assigns(:unwelcome_driver)
    assert_select "unwelcome_driver:root[id=#{up.id}]" +
        "[href=#{user_unwelcome_driver_url(:user_id => up.user.id,
                                              :id => up.id)}]" do
      assert_select "user[id=#{up.driver.id}][href=#{user_url(
        up.driver)}]" do
        assert_select "first_name", up.driver.first_name
        assert_select "last_name", up.driver.last_name
        assert_select "nick_name", up.driver.nick_name
      end
    end
  end


  test "cannot add a driver to black list without credentials" do
    user = users(:donald_duck)
    driver = users(:mickey_mouse)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => user.id,
          :unwelcome_driver => { :id => driver.id }
    end
    assert_response :unauthorized
  end


  test "cannot add a driver to someone other's" do
    user = users(:donald_duck)
    other_user = users(:user_N)
    driver = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => other_user.id,
          :unwelcome_driver => { :id => driver.id }
    end
    assert_response :forbidden
  end


  test "not found if post with wrong user id" do
    user = users(:donald_duck)
    driver = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => -1,
          :unwelcome_driver => { :id => driver.id }
    end
    assert_response :not_found
  end


  test "add a driver with wrong params" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => user.id,
          :unwelcome_driver => { :id => -1 }
    end
    assert_response :unprocessable_entity
  end


  # DELETE


  test "delete an entry" do
    entry = black_list_drivers_entries(:one)
    user = entry.user
    driver = entry.driver
    set_authorization_header(entry.user.nick_name, entry.user.password)
    assert_difference('BlackListDriversEntry.count', -1) do
      delete :destroy, :user_id => entry.user.id, :id => entry.id
    end
    assert_response :ok
    #
    assert !user.drivers_in_black_list.include?(driver)
  end


  test "cannot delete without credentials" do
    entry = black_list_drivers_entries(:one)
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => entry.user.id, :id => entry.id
    end
    assert_response :unauthorized
  end


  test "cannot delete someone's other entry" do
    entry = black_list_drivers_entries(:one)
    other_user = users(:donald_duck)
    set_authorization_header(other_user.nick_name,
                             other_user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => entry.user.id, :id => entry.id
    end
    assert_response :forbidden
  end


  test "not found if delete a non existent user" do
    entry = black_list_drivers_entries(:one)
    set_authorization_header(entry.user.nick_name, entry.user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => -1, :id => entry.id
    end
    assert_response :not_found
  end


  test "not found if delete a non existent id" do
    entry = black_list_drivers_entries(:one)
    set_authorization_header(entry.user.nick_name, entry.user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => entry.user.id, :id => -1
    end
    assert_response :not_found
  end
end
