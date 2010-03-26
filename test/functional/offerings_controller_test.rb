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

class OfferingsControllerTest < ActionController::TestCase

  def setup
    AuthenticatorFactory.set_factory(AuthenticatorFactoryMock.new)
    #
    @processor = OfferingProcessorMock.new
    OfferingProcessorFactory.set_factory(OfferingProcessorMockFactory.
                                         new(@processor))
  end


  def tear_down
    AuthenticatorFactory.clear_factory
    #
    OfferingProcessorFactory.clear_factory
  end


  test "get a specific offering" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show,
        :id => offerings(:donald_duck_offering_n_2_dep_in_the_past).id
    assert_response :success
    assert_not_nil assigns(:offering)
  end


  test "get a non existent offering" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => -1
    assert_response :not_found
  end


  test "cannot see an offering without authorization" do
    get :show, :id => offerings(:donald_duck_offering_n_1).id
    assert_response :unauthorized
  end


  test "can see only my offerings" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => offerings(:mickey_mouse_offering_n_1).id
    assert_response :forbidden
  end


  test "redirect if I get an offering already used" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => offerings(:offering_with_used_offering).id
    assert_response :temporary_redirect
    assert_redirected_to :controller => "used_offerings",
        :action => "show",
      :id => offerings(:offering_with_used_offering).used_offering.id
  end


  test "create a new offering" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    departure_time = 1.hour.from_now
    assert_difference('Offering.count', 1) do
      post :create, :offering => {
        :departure_place_id => places(:sede_di_via_ravasi).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        :departure_time => departure_time,
        :seating_capacity => 1,
        :expiry_time => 15.minutes.from_now }
    end
    assert_response :created
    assert_not_nil assigns(:offering)
    offering = assigns(:offering)
    assert_equal users(:donald_duck), offering.offerer
    # check travel duration and length read from edges
    edge = edges(:sede_via_ravasi_sede_via_dunant)
    assert_equal edge.length, offering.length
    assert_equal departure_time + edge.travel_duration.minutes,
        offering.arrival_time
    # check the processor
    assert @processor.process_incoming_offering_called?
  end


  test "create a new offering but invalid" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Offering.count', 0) do
      post :create, :offering => {
        :departure_place_id => places(:sede_di_via_ravasi).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        # departure_time missed
        :seating_capacity => 1,
        :expiry_time => 15.minutes.from_now }
    end
    assert_response :unprocessable_entity
    # check the processor
    assert ! @processor.process_incoming_offering_called?
  end


  test "create a new offering but departure place and arrival place \
      is not an edge by car" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Offering.count', 0) do
      post :create, :offering => {
        :departure_place_id => places(:sede_di_via_ravasi).id,
        :arrival_place_id => places(:stazione_fnm).id,
        :departure_time => 1.hour.from_now,
        :seating_capacity => 1,
        :expiry_time => 30.minutes.from_now }
    end
    assert_response :unprocessable_entity
    # check the processor
    assert ! @processor.process_incoming_offering_called?
  end


  test "cannot create an offering without authorization" do
    assert_difference('Offering.count', 0) do
      post :create, :offering => {
        :departure_place_id => places(:sede_di_via_ravasi).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        :departure_time => 1.hour.from_now,
        :arrival_time => 2.hours.from_now,
        :length => 6000,
        :seating_capacity => 1,
        :expiry_time => 15.minutes.from_now,
        :offerer_id => users(:donald_duck).id }
    end
    assert_response :unauthorized
    # check the processor
    assert ! @processor.process_incoming_offering_called?
  end


  test "offerer is specified by credentials in HTTP auth header" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    post :create, :offering => {
      :departure_place_id => places(:sede_di_via_ravasi).id,
      :arrival_place_id => places(:sede_di_via_dunant).id,
      :departure_time => 1.hour.from_now,
      :seating_capacity => 1,
      :expiry_time => 15.minutes.from_now,
      :offerer_id => users(:donald_duck).id}
    assert_response :created
    assert_not_nil assigns(:offering)
    just_created = assigns(:offering)
    assert_equal users(:mickey_mouse), just_created.offerer
    # check the processor
    assert @processor.process_incoming_offering_called?
  end


  test "cannot create an offering with invalid data" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Offering.count', 0) do
      post :create, :offering => {
        :departure_place_id => places(:sede_di_via_ravasi).id,
        :arrival_place_id => places(:sede_di_via_dunant).id,
        :departure_time => 1.hour.ago,
        :seating_capacity => 1,
        :expiry_time => 15.minutes.from_now }
    end
    assert_response :unprocessable_entity
    # check the processor
    assert ! @processor.process_incoming_offering_called?
  end


  test "delete an offering" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Offering.count', -1) do
      delete :destroy,
          :id => offerings(:mickey_mouse_offering_n_1).id
    end
    assert_response :success
    # check the processor
    assert @processor.revoke_offering_called?
  end


  test "delete an offering without credentials" do
    assert_difference('Offering.count', 0) do
      delete :destroy,
          :id => offerings(:mickey_mouse_offering_n_1).id
    end
    assert_response :unauthorized
    # check the processor
    assert ! @processor.revoke_offering_called?
  end


  test "try to delete an offering with a non-existent id" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Offering.count', 0) do
      delete :destroy, :id => -1
    end
    assert_response :not_found
    # check the processor
    assert ! @processor.revoke_offering_called?
  end


  test "cannot delete a chilled offering" do
    chilled_offering = offerings(:frozen_offering)
    assert chilled_offering.chilled?
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Offering.count', 0) do
      delete :destroy, :id => chilled_offering.id
    end
    assert_response :method_not_allowed
    # check the processor
    assert ! @processor.revoke_offering_called?
  end


  test "cannot delete a someone other's offering" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('Offering.count', 0) do
      delete :destroy,
          :id => offerings(:mickey_mouse_offering_n_1).id
    end
    assert_response :forbidden
    # check the processor
    assert ! @processor.revoke_offering_called?
  end


  test "redirect if I try to delete an offering in use" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('Offering.count', 0) do
      delete :destroy,
          :id => offerings(:offering_with_used_offering).id
    end
    assert_response :temporary_redirect
    assert_redirected_to(:controller => "used_offerings",
                         :action => "destroy",
      :id => offerings(:offering_with_used_offering).used_offering.id)
    # check the processor
    assert ! @processor.revoke_offering_called?
  end


  private

  class OfferingProcessorMockFactory

    def initialize(processor)
      @processor = processor
    end


    def build_processor
      @processor
    end

  end # class OfferingProcessorMockFactory


  class OfferingProcessorMock

    def initialize
      @process_incoming_offering_called = false
      @revoke_offering_called = false
    end


    def process_incoming_offering_called?
      @process_incoming_offering_called
    end


    def revoke_offering_called?
      @revoke_offering_called
    end


    def clear_calls
      @process_incoming_offering_called = false
      @revoke_offering_called = false
    end


    def process_incoming_offering(offering)
      @process_incoming_offering_called = true
    end


    def revoke_offering(offering)
      @revoke_offering_called = true
    end


  end # class OfferingProcessorMock

end
