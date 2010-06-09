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

class InteractionBetweenUsedOfferingAndOfferingTest <
  ActionController::IntegrationTest


  fixtures :offerings, :used_offerings


  def setup
    AuthenticatorFactory.set_factory(AuthenticatorFactoryMock.new)
    #
    OfferingProcessorFactory.set_factory(OfferingProcessorMockFactory.
                                         new)
  end


  def teardown
    DemandProcessorFactory.clear_factory
    #
    OfferingProcessorFactory.clear_factory
  end


  test "after deleting a used offering the offering doesn't exist" do
    used_offering = used_offerings(:used_offering_2)
    url = offering_url(used_offering.offering)
    auth_string = encode_authorization_value(used_offering.offerer.
                                             nick_name,
                                             used_offering.offerer.
                                            password)
    #
    get url, nil, "HTTP_AUTHORIZATION" => auth_string
    assert_response :temporary_redirect, :location =>
        used_offering_url(used_offering)
    #
    delete(used_offering_url(used_offering), nil,
           "HTTP_AUTHORIZATION" => auth_string, "ACCEPT" => "text/xml")
    assert_response :success
    #
    get url, nil, "HTTP_AUTHORIZATION" => auth_string
    assert_response :not_found
  end


  private

  class OfferingProcessorMockFactory

    def build_processor
      OfferingProcessorMock.new
    end

  end


  class OfferingProcessorMock

    def revoke_used_offering(used_offering)
      true
    end


    def revoke_offering(offering)
      true
    end

  end


end
