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

class DemandsControllerTest < ActionController::TestCase


  def setup
    @processor = DemandProcessorMock.new
    DemandProcessorFactory.set_factory(
      DemandProcessorMockFactory.new(@processor))
  end


  def tear_down
    DemandProcessorFactory.clear_factory
  end


  test "get a specific demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => demands(:mickey_mouse_demand_n_1).id
    assert_response :success
    assert_not_nil assigns(:demand)
  end


  test "get a wrong-id-demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => -1
    assert_response :not_found
  end


  test "get a demand without credentials" do
    get :show, :id => demands(:mickey_mouse_demand_n_1).id
    assert_response :unauthorized
  end


  test "cannot get someone's other demand" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => demands(:mickey_mouse_demand_n_1).id
    assert_response :forbidden
  end


  test "redirect if I get a demand already fulfilled" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => demands(:demand_with_solution_n_1).id
    assert_response :temporary_redirect
    assert_redirected_to :controller => "fulfilled_demands",
        :action => "show",
        :id => demands(:demand_with_solution_n_1).fulfilled_demand.id
  end


  test "create a demand" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Demand.count', 1) do
      post :create, :demand => {
        :departure_place_id => places(:stazione_fnm).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        :earliest_departure_time => 1.hour.from_now,
        :latest_arrival_time => 6.hours.from_now,
        :expiry_time => 15.minutes.from_now }
    end
    assert_response :created
    assert_not_nil assigns(:demand)
    # check the processor
    assert @processor.process_incoming_demand_called?
  end


  test "demand suitor is the user authenticated" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Demand.count', 1) do
      post :create, :demand => {
        :departure_place_id => places(:stazione_fnm).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        :earliest_departure_time => 1.hour.from_now,
        :latest_arrival_time => 6.hours.from_now,
        :expiry_time => 15.minutes.from_now,
        :suitor_id => users(:mickey_mouse).id # <----------
      }
    end
    assert_response :created
    assert_not_nil assigns(:demand)
    just_created = assigns(:demand)
    assert_equal users(:donald_duck).id, just_created.suitor_id
    assert_equal users(:donald_duck), just_created.suitor
    # check the processor
    assert @processor.process_incoming_demand_called?
  end


  test "cannot create a demand without credentials" do
    assert_difference('Demand.count', 0) do
      post :create, :demand => {
        :departure_place_id => places(:stazione_fnm).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        :earliest_departure_time => 1.hour.from_now,
        :latest_arrival_time => 6.hours.from_now,
        :expiry_time => 15.minutes.from_now }
    end
    assert_response :unauthorized
    # check the processor
    assert ! @processor.process_incoming_demand_called?
  end


  test "cannot create a demand with wrong params" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Demand.count', 0) do
      post :create, :demand => {
        :departure_place_id => places(:stazione_fnm).id,
        :arrival_place_id => -1,
        :earliest_departure_time => 1.hour.from_now,
        :latest_arrival_time => 6.hours.from_now,
        :expiry_time => 15.minutes.from_now }
    end
    assert_response :unprocessable_entity
    # check the processor
    assert ! @processor.process_incoming_demand_called?
  end


  test "delete a demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Demand.count', -1) do
      delete :destroy, :id => demands(:mickey_mouse_demand_n_1).id
    end
    assert_response :success
    # check the processor
    assert @processor.revoke_demand_called?
  end


  test "cannot delete a non existent demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Demand.count', 0) do
      delete :destroy, :id => -1
    end
    assert_response :not_found
    # check the processor
    assert ! @processor.revoke_demand_called?
  end


  test "cannot delete a demand without credentials" do
    assert_difference('Demand.count', 0) do
      delete :destroy, :id => demands(:mickey_mouse_demand_n_1).id
    end
    assert_response :unauthorized
    # check the processor
    assert ! @processor.revoke_demand_called?
  end


  test "cannot delete a someone other's demand" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Demand.count', 0) do
      delete :destroy, :id => demands(:mickey_mouse_demand_n_1).id
    end
    assert_response :forbidden
    # check the processor
    assert ! @processor.revoke_demand_called?
  end


  test "redirect if I try to delete a chilled demand" do
    chilled_demand = demands(:demand_with_solution_n_1)
    assert chilled_demand.chilled?
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Demand.count', 0) do
      delete :destroy, :id => chilled_demand.id
    end
    assert_response :temporary_redirect
    assert_redirected_to :controller => "fulfilled_demands",
        :action => "destroy", :id => chilled_demand.
                                        fulfilled_demand.id
    # check the processor
    assert ! @processor.revoke_demand_called?
  end


  test "redirect if I try to delete a demand already fulfilled" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Demand.count', 0) do
      delete :destroy, :id => demands(:demand_with_solution_n_1).id
    end
    assert_response :temporary_redirect
    assert_redirected_to :controller => "fulfilled_demands",
        :action => "destroy", :id =>
          demands(:demand_with_solution_n_1).
          fulfilled_demand.id
    # check the processor
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
      @process_incoming_demand_called = false
      @revoke_demand_called = false
    end


    def process_incoming_demand_called?
      @process_incoming_demand_called
    end


    def revoke_demand_called?
      @revoke_demand_called
    end


    def process_incoming_demand(demand)
      @process_incoming_demand_called = true
    end


    def revoke_demand(demand)
      @revoke_demand_called = true
    end


  end # class DemandProcessorMock


end
