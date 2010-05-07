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


test "get index" do
    user = users(:user_N)
    set_authorization_header(user.nick_name, user.password)
    get :index, :user_id => user.id
    assert_response :success
    #
    assert_not_nil assigns(:unwelcome_drivers)
  end


  test "cannot get index without credentials" do
    user = users(:user_N)
    get :index, :user_id => user.id
    assert_response :unauthorized
  end


  test "cannot get someone's other index" do
    user = users(:user_N)
    set_authorization_header(user.nick_name, user.password)
    get :index, :user_id => users(:donald_duck).id
    assert_response :forbidden
  end


  # get ids


  test "get" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(user.nick_name, user.password)
    get :show, :user_id => user.id, :id => unwanted_driver.id
    assert_response :success
    assert_not_nil assigns(:unwelcome_driver)
    up = assigns(:unwelcome_driver)
    assert_equal unwanted_driver, up
    # testing response content
    assert_select "user[id=#{up.id}][href=#{user_url(up)}]" do
      assert_select "first_name", up.first_name
      assert_select "last_name", up.last_name
      assert_select "nick_name", up.nick_name
    end
  end


  test "can get only XML" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(user.nick_name, user.password)
    get :show, :format => "html", :user_id => user.id,
        :id => unwanted_driver.id
    assert_response :not_acceptable
  end


  test "cannot get without credentials" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    get :show, :user_id => user.id, :id => unwanted_driver.id
    assert_response :unauthorized
  end


  test "cannot get someone other's" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :user_id => user.id, :id => unwanted_driver.id
    assert_response :forbidden
  end


  test "get with wrong user id" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(user.nick_name, user.password)
    get :show, :user_id => -1, :id => unwanted_driver.id
    assert_response :not_found
  end


  test "get with wrong id" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(user.nick_name, user.password)
    get :show, :user_id => user.id, :id => -1
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
          :unwelcome_user => driver.id
    end
    assert_response :created
    assert_not_nil assigns(:unwelcome_driver)
    up = assigns(:unwelcome_driver)
    assert_equal driver, up
    assert user.drivers_in_black_list.include?(up)
    # testing response content
    assert_select "user[id=#{up.id}][href=#{user_url(up)}]" do
      assert_select "first_name", up.first_name
      assert_select "last_name", up.last_name
      assert_select "nick_name", up.nick_name
    end
  end


  test "add a driver to black list xhr" do
    user = users(:donald_duck)
    driver = users(:mickey_mouse)
    #
    assert !user.drivers_in_black_list.include?(driver)
    #
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 1) do
      xhr(:post, :create, :user_id => user.id,
          :unwelcome_user => driver.id)
    end
    assert_response :success
    assert_not_nil assigns(:unwelcome_driver)
    up = assigns(:unwelcome_driver)
    assert_equal driver, up
    assert user.drivers_in_black_list.include?(up)
  end


  test "cannot add a driver to black list without credentials" do
    user = users(:donald_duck)
    driver = users(:mickey_mouse)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => user.id,
          :unwelcome_user =>  driver.id
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
          :unwelcome_user => driver.id
    end
    assert_response :forbidden
  end


  test "not found if post with wrong user id" do
    user = users(:donald_duck)
    driver = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => -1,
          :unwelcome_user => driver.id
    end
    assert_response :not_found
  end


  test "add a driver with wrong params" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => user.id,
          :unwelcome_user => -1
    end
    assert_response :unprocessable_entity
  end


  test "add him her self to black list" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      post :create, :user_id => user.id,
          :unwelcome_user => user.id
    end
    assert_response :unprocessable_entity
  end


  # DELETE


  test "delete an entry" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', -1) do
      delete :destroy, :user_id => user.id,
          :id => unwanted_driver.id
    end
    assert_response :ok
    #
    user.reload
    assert !user.drivers_in_black_list.include?(unwanted_driver)
  end


  test "delete an entry xhr" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', -1) do
      xhr(:delete, :destroy, :user_id => user.id,
          :id => unwanted_driver.id)
    end
    assert_response :ok
    #
    user.reload
    assert !user.drivers_in_black_list.include?(unwanted_driver)
  end


  test "cannot delete without credentials" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => user.id,
          :id => unwanted_driver.id
    end
    assert_response :unauthorized
  end


  test "cannot delete someone's other entry" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => user.id,
          :id => unwanted_driver.id
    end
    assert_response :forbidden
  end


  test "not found if delete a non existent user" do
    user = users(:user_N)
    unwanted_driver = user.drivers_in_black_list[0]
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => -1, :id => unwanted_driver.id
    end
    assert_response :not_found
  end


  test "not found if delete a non existent id" do
    user = users(:user_N)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('BlackListDriversEntry.count', 0) do
      delete :destroy, :user_id => user.id, :id => -1
    end
    assert_response :not_found
  end

end
