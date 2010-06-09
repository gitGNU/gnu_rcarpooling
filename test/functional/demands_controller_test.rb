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
    AuthenticatorFactory.set_factory(AuthenticatorFactoryMock.new)
    #
    @processor = DemandProcessorMock.new
    DemandProcessorFactory.set_factory(
      DemandProcessorMockFactory.new(@processor))
  end


  def teardown
    DemandProcessorFactory.clear_factory
    #
    AuthenticatorFactory.clear_factory
  end


  test "get all demands" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    get :index
    assert_response :success
    assert_not_nil assigns(:demands)
    demands = assigns(:demands)
    assert_equal user.demands, demands
    # testing response content
    assert_select "demands:root[suitor_id=#{user.id}]" +
        "[suitor_href=#{user_url(user)}]" do
      demands.each do |demand|
        assert_select "demand[id=#{demand.id}]" +
            "[href=#{demand_url(demand)}]"
      end
    end
  end


  test "get all demands format html" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    get :index, :format => "html"
    assert_response :success
  end


  test "cannot get all demands without credentials" do
    get :index
    assert_response :unauthorized
  end


  test "get the form for a new demand" do
    get :new
    assert_response :success
    assert_not_nil assigns(:demand)
    assert_not_nil assigns(:places)
  end


  test "get a specific demand" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => demands(:mickey_mouse_demand_n_1).id
    assert_response :success
    assert_not_nil assigns(:demand)
    # testing response content
    d = assigns(:demand)
    assert_select "demand:root[id=#{d.id}][href=#{demand_url(d)}]" do
      assert_select "suitor[id=#{d.suitor.id}]" +
          "[href=#{user_url(d.suitor)}]"
      assert_select "earliest_departure_time",
          d.earliest_departure_time.xmlschema
      assert_select "latest_arrival_time",
          d.latest_arrival_time.xmlschema
      assert_select "expiry_time",
          d.expiry_time.xmlschema
      assert_select "created_at", d.created_at.xmlschema
      assert_select "departure_place[id=#{d.departure_place.id}]" +
          "[href=#{place_url(d.departure_place)}]"
      assert_select "arrival_place[id=#{d.arrival_place.id}]" +
          "[href=#{place_url(d.arrival_place)}]"
    end
  end


  test "get a specific demand format html" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :format => "html",
        :id => demands(:mickey_mouse_demand_n_1).id
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
        :earliest_departure_time => 1.week.from_now,
        :latest_arrival_time => 8.days.from_now,
        :expiry_time => 15.minutes.from_now }
    end
    assert_response :created
    assert_not_nil assigns(:demand)
    # check the processor
    assert @processor.process_incoming_demand_called?
    # testing response content
    d = assigns(:demand)
    assert_select "demand:root[id=#{d.id}][href=#{demand_url(d)}]" do
      assert_select "suitor[id=#{d.suitor.id}][href=#{user_url(d.suitor)}]"
      assert_select "earliest_departure_time",
          d.earliest_departure_time.xmlschema
      assert_select "latest_arrival_time",
          d.latest_arrival_time.xmlschema
      assert_select "expiry_time",
          d.expiry_time.xmlschema
      assert_select "created_at", d.created_at.xmlschema
      assert_select "departure_place[id=#{d.departure_place.id}]" +
          "[href=#{place_url(d.departure_place)}]"
      assert_select "arrival_place[id=#{d.arrival_place.id}]" +
          "[href=#{place_url(d.arrival_place)}]"
    end
  end


  test "create a demand format html" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Demand.count', 1) do
      post :create, :format => "html", :demand => {
        :departure_place_id => places(:stazione_fnm).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        :earliest_departure_time => 1.week.from_now,
        :latest_arrival_time => 8.days.from_now,
        :expiry_time => 15.minutes.from_now }
    end
    assert_not_nil assigns(:demand)
    assert_redirected_to demand_url(assigns(:demand))
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
        :earliest_departure_time => 1.week.from_now,
        :latest_arrival_time => 8.days.from_now,
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


  test "cannot create a demand with wrong params format html" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Demand.count', 0) do
      post :create, :format => "html",
          :demand => {
        :departure_place_id => places(:stazione_fnm).id,
        :arrival_place_id => -1,
        :earliest_departure_time => 1.hour.from_now,
        :latest_arrival_time => 6.hours.from_now,
        :expiry_time => 15.minutes.from_now }
    end
    assert_template "new"
    assert_not_nil assigns(:demand).errors
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


  test "delete a demand format html" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Demand.count', -1) do
      delete :destroy, :id => demands(:mickey_mouse_demand_n_1).id,
          :format => "html"
    end
    assert_redirected_to demands_url
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


  test "cannot delete an undeletable demand" do
    demand = demands(:mickey_mouse_demand_n_2_dep_in_past)
    assert !demand.deletable?
    set_authorization_header(demand.suitor.nick_name,
                             demand.suitor.password)
    assert_difference('Demand.count', 0) do
      delete :destroy, :id => demand.id
    end
    assert_response :method_not_allowed
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
