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

class OfferingProcessorTest < ActiveSupport::TestCase

  def setup
    @notifier = NotifierMock.new
    @offering_processor = OfferingProcessor.new(@notifier)
  end


  test "revoke used offering" do
    used_offering = used_offerings(:donald_duck_offering_n_1_used)
    fulfilled_demands = FulfilledDemand.
      find_all_fulfilled_by_a_used_offering(used_offering)
    number_of_fulfilled_demands = fulfilled_demands.size
    #
    assert !fulfilled_demands.empty?
    @offering_processor.revoke_used_offering(used_offering)
    #
    fulfilled_demands = FulfilledDemand.
      find_all_fulfilled_by_a_used_offering(used_offering)
    assert fulfilled_demands.empty?
    # check notifications
    notifications = @notifier.notifications
    assert !notifications.empty?
    assert_equal number_of_fulfilled_demands, notifications.size
  end


  test "process incoming offering" do
    offering = offerings(:donald_duck_offering_n_1)
    @offering_processor.process_incoming_offering(offering)
    assert !@notifier.scheduled_notifications.empty?
    assert_equal 1, @notifier.scheduled_notifications.size
    assert_not_nil offering.passengers_list_job_number
  end


  test "revoke offering, cancel scheduled notification" do
    offering = offerings(:donald_duck_offering_n_1)
    # I have to schedule a notify
    @offering_processor.process_incoming_offering(offering)
    assert_equal 1, @notifier.scheduled_notifications.size
    #
    @offering_processor.revoke_offering(offering)
    # now the job does not exist
    assert @notifier.scheduled_notifications.empty?
    assert_nil offering.passengers_list_job_number
  end

end
