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

class InteractionBetweenFulfilledDemandAndDemandTest < ActionController::IntegrationTest

  fixtures :all


  def setup
    DemandProcessorFactory.set_factory(DemandProcessorMockFactory.new)
  end


  def tear_down
    DemandProcessorFactory.clear_factory
  end


  test "after deleting a fulfilled demand the rel demand does not exist" do
    fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_2)
    url_of_demand = demand_url(fulfilled_demand.demand)
    #
    auth_string = encode_authorization_value(fulfilled_demand.suitor.nick_name,
                                             fulfilled_demand.suitor.password)
    #
    get(url_of_demand, nil, "HTTP_AUTHORIZATION" => auth_string)
    assert_response :temporary_redirect,
        :location => fulfilled_demand_url(fulfilled_demand)
    #
    delete(fulfilled_demand_url(fulfilled_demand), nil,
           "HTTP_AUTHORIZATION" => auth_string)
    assert_response :success
    #
    get(url_of_demand, nil, "HTTP_AUTHORIZATION" => auth_string)
    assert_response :not_found
  end


  private


  class DemandProcessorMockFactory
    def build_processor
      DemandProcessorMock.new
    end
  end


  class DemandProcessorMock
    def revoke_fulfilled_demand(fulfilled_demand)
      true
    end


    def revoke_demand(demand)
      true
    end

  end

end
