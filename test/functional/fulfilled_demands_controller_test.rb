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

class FulfilledDemandsControllerTest < ActionController::TestCase


  def setup
    AuthenticatorFactory.set_factory(AuthenticatorFactoryMock.new)
    #
    @processor = DemandProcessorMock.new
    DemandProcessorFactory.set_factory(
      DemandProcessorMockFactory.new(@processor))
  end


  def tear_down
    AuthenticatorFactory.clear_factory
    #
    DemandProcessorFactory.clear_factory
  end


  test "get a specific fulfilled demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => fulfilled_demands(:fulfilled_demand_n_1).id
    assert_response :success
    assert_not_nil assigns(:fulfilled_demand)
  end


  test "get a wrong-id fulfilled demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => -1
    assert_response :not_found
  end


  test "get a fulfilled demand without credentials" do
    get :show, :id => fulfilled_demands(:fulfilled_demand_n_1).id
    assert_response :unauthorized
  end


  test "cannot get someone's other demand" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => fulfilled_demands(:fulfilled_demand_n_1).id
    assert_response :forbidden
  end


  test "delete a fulfilled demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('FulfilledDemand.count', -1) do
      delete :destroy, :id => fulfilled_demands(:fulfilled_demand_n_2).id
    end
    assert_response :success
    # check the processor
    assert @processor.revoke_fulfilled_demand_called?
    assert @processor.revoke_demand_called?
  end


  test "cannot delete a non existent fulfilled demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('FulfilledDemand.count', 0) do
      delete :destroy, :id => -1
    end
    assert_response :not_found
    # check the processor
    assert ! @processor.revoke_fulfilled_demand_called?
    assert ! @processor.revoke_demand_called?
  end


  test "cannot delete a fulfilled demand without credentials" do
    assert_difference('FulfilledDemand.count', 0) do
      delete :destroy, :id => fulfilled_demands(:fulfilled_demand_n_2).id
    end
    assert_response :unauthorized
    # check the processor
    assert ! @processor.revoke_fulfilled_demand_called?
    assert ! @processor.revoke_demand_called?
  end


  test "cannot delete a someone other's fulfilled demand" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('FulfilledDemand.count', 0) do
      delete :destroy, :id => fulfilled_demands(:fulfilled_demand_n_2).id
    end
    assert_response :forbidden
    # check the processor
    assert ! @processor.revoke_fulfilled_demand_called?
    assert ! @processor.revoke_demand_called?
  end


  test "cannot delete a chilled fulfilled demand" do
    chilled_fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_1)
    assert chilled_fulfilled_demand.chilled?
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('FulfilledDemand.count', 0) do
      delete :destroy, :id => chilled_fulfilled_demand.id
    end
    assert_response :method_not_allowed
    # check the processor
    assert ! @processor.revoke_fulfilled_demand_called?
    assert ! @processor.revoke_demand_called?
  end


  private


  class DemandProcessorMockFactory

    def initialize(processor)
      @processor = processor
    end


    def build_processor
      @processor
    end


  end # class DemandProcessorMockFactory


  class DemandProcessorMock

    def initialize
      @revoke_fulfilled_demand_called = false
      @revoke_demand_called = false
    end


    def revoke_fulfilled_demand_called?
      @revoke_fulfilled_demand_called
    end


    def revoke_demand_called?
      @revoke_demand_called
    end


    def revoke_fulfilled_demand(fulfilled_demand)
      @revoke_fulfilled_demand_called = true
    end


    def revoke_demand(demand)
      @revoke_demand_called = true
    end

  end # class DemandProcessorMock

end
