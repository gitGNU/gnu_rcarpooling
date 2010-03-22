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

class UsedOfferingsControllerTest < ActionController::TestCase


  def setup
    @processor = OfferingProcessorMock.new
    OfferingProcessorFactory.set_factory(OfferingProcessorMockFactory.
                                         new(@processor))
  end


  def tear_down
    OfferingProcessorFactory.clear_factory
  end


  test "get a specific used offering" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => used_offerings(:donald_duck_offering_n_1_used).id
    assert_response :success
    assert_not_nil assigns(:used_offering)
  end


  test "get a specific used offering with non existent id" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => -1
    assert_response :not_found
  end


  test "cannot get someone other's offering" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => used_offerings(:used_offering_2).id
    assert_response :forbidden
  end


  test "cannot get a used offering without credentials" do
    get :show, :id => used_offerings(:donald_duck_offering_n_1_used).id
    assert_response :unauthorized
  end


  test "delete a used offering" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('UsedOffering.count', -1) do
      delete :destroy, :id => used_offerings(:used_offering_2).id
    end
    assert_response :success
    # check the processor
    assert @processor.revoke_used_offering_called?
    assert @processor.revoke_offering_called?
  end


  test "cannot delete a used offering without credentials" do
    assert_difference('UsedOffering.count', 0) do
      delete :destroy, :id => used_offerings(:used_offering_2).id
    end
    assert_response :unauthorized
    # check the processor
    assert ! @processor.revoke_used_offering_called?
    assert ! @processor.revoke_offering_called?
  end


  test "try to delete a used offering with a non-existent id" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('UsedOffering.count', 0) do
      delete :destroy, :id => -1
    end
    assert_response :not_found
    # check the processor
    assert ! @processor.revoke_used_offering_called?
    assert ! @processor.revoke_offering_called?
  end


  test "cannot delete a chilled used offering" do
    chilled_offering =
        used_offerings(:used_offering_3_to_a_frozen_offering)
    assert chilled_offering.chilled?
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    assert_difference('UsedOffering.count', 0) do
      delete :destroy, :id => chilled_offering.id
    end
    assert_response :method_not_allowed
    # check the processor
    assert ! @processor.revoke_used_offering_called?
    assert ! @processor.revoke_offering_called?
  end


  test "cannot delete a someone other's offering" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert_difference('UsedOffering.count', 0) do
      delete :destroy, :id => used_offerings(:used_offering_2).id
    end
    assert_response :forbidden
    # check the processor
    assert ! @processor.revoke_used_offering_called?
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
      @revoke_used_offering_called = false
      @revoke_offering_called = false
    end


    def revoke_used_offering(used_offering)
      @revoke_used_offering_called = true
    end


    def revoke_offering(offering)
      @revoke_offering_called = true
    end


    def revoke_used_offering_called?
      @revoke_used_offering_called
    end


    def revoke_offering_called?
      @revoke_offering_called
    end

  end # class OfferingProcessorMock

end
