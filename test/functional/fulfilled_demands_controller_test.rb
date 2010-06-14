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


  def teardown
    AuthenticatorFactory.clear_factory
    #
    DemandProcessorFactory.clear_factory
  end


  test "get a specific fulfilled demand" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :format => 'xml',
        :id => fulfilled_demands(:fulfilled_demand_N).id
    assert_response :success
    assert_equal 'application/xml', @response.content_type
    assert_not_nil assigns(:fulfilled_demand)
    # testing response content
    fd = assigns(:fulfilled_demand)
    assert_select "fulfilled_demand:root[id=#{fd.id}]" +
        "[href=#{fulfilled_demand_url(fd)}]" do
      assert_select "demand[id=#{fd.demand.id}]" +
          "[href=#{demand_url(fd.demand)}]"
      assert_select "suitor[id=#{fd.suitor.id}]" +
          "[href=#{user_url(fd.suitor)}]"
      assert_select "departure_place[id=#{fd.departure_place.id}]" +
          "[href=#{place_url(fd.departure_place)}]"
      assert_select "departure_time", fd.departure_time.xmlschema
      assert_select "arrival_place[id=#{fd.arrival_place.id}]" +
          "[href=#{place_url(fd.arrival_place)}]"
      assert_select "arrival_time", fd.arrival_time.xmlschema
      assert_select "guaranteed_since", fd.guaranteed_since.xmlschema
      assert_select "car" do
        assert_select "offering[id=#{fd.vehicle_offering.id}]" +
            "[href=#{used_offering_url(fd.vehicle_offering)}]"
        assert_select "travel_duration", fd.car_travel_duration.to_s
        assert_select "length", fd.car_length.to_s
        assert_select "departure_place[id=#{fd.car_departure_place.id}]" +
          "[href=#{place_url(fd.car_departure_place)}]"
        assert_select "departure_time", fd.car_departure_time.xmlschema
        assert_select "arrival_place[id=#{fd.car_arrival_place.id}]" +
          "[href=#{place_url(fd.car_arrival_place)}]"
        assert_select "arrival_time", fd.car_arrival_time.xmlschema
      end
      if fd.has_initial_walk?
        assert_select "initial_walk" do
          assert_select "travel_duration", fd.initial_walk_duration.to_s
          assert_select "length", fd.initial_walk_length.to_s
        end
      end
      if fd.has_final_walk?
        assert_select "final_walk" do
          assert_select "travel_duration", fd.final_walk_duration.to_s
          assert_select "length", fd.final_walk_length.to_s
        end
      end
    end
  end


  test "get a specific fulfilled demand format html" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => fulfilled_demands(:fulfilled_demand_N).id
    assert_response :success
    assert_equal 'text/html', @response.content_type
    assert_template "show"
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
      delete :destroy, :format => 'xml',
          :id => fulfilled_demands(:fulfilled_demand_n_2).id
    end
    assert_response :success
    # check the processor
    assert @processor.revoke_fulfilled_demand_called?
    assert @processor.revoke_demand_called?
  end


  test "delete a fulfilled demand format html" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('FulfilledDemand.count', -1) do
      delete :destroy, :id => fulfilled_demands(:fulfilled_demand_n_2).id
    end
    assert_redirected_to demands_url
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
