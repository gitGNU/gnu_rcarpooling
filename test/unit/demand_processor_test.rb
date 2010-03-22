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

class DemandProcessorTest < ActiveSupport::TestCase

  def setup
    @notifier = NotifierMock.new
    @processor = DemandProcessor.new(@notifier)
  end


  test "revoke fulfilled demand" do
    fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_2)
    used_offering = fulfilled_demand.used_offering
    offering = used_offering.offering
    assert !used_offering.frozen? # rails method!
    @processor.revoke_fulfilled_demand(fulfilled_demand)
    assert used_offering.frozen? # rails method!
    assert !offering.in_use?
  end


  test "another revoking of fulfilled demand" do
    fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_1)
    used_offering = fulfilled_demand.used_offering
    offering = used_offering.offering
    assert !used_offering.frozen? # rails method!
    previous_seating_capacity = used_offering.seating_capacity
    @processor.revoke_fulfilled_demand(fulfilled_demand)
    used_offering.reload
    offering.reload
    assert !used_offering.frozen? # rails method!
    assert_equal previous_seating_capacity + 1,
        used_offering.seating_capacity
    assert offering.in_use?
  end


  test "process incoming demand" do
    demand = demands(:mickey_mouse_demand_n_1)
    @processor.process_incoming_demand(demand)
    # should send the default reply: no solution
    assert_equal 1, @notifier.scheduled_notifications.size
    assert_not_nil demand.default_reply_job_number
  end


  test "revoke demand, cancel the at job scheduled" do
    demand = demands(:mickey_mouse_demand_n_1)
    @processor.process_incoming_demand(demand)
    assert_equal 1, @notifier.scheduled_notifications.size
    #
    @processor.revoke_demand(demand)
    # now the job does not exist
    assert @notifier.scheduled_notifications.empty?
    assert_nil demand.default_reply_job_number
  end

end
