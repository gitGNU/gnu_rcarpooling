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

class SolutionBuilderTest < ActiveSupport::TestCase
  # demand1 : dep from y1, arr y2
  # offering1: dep from y3, arr y4
  # offering2: dep from y1, arr y4

  def setup
    Demand.destroy_all
    Offering.destroy_all
    @notifier = NotifierMock.new
    @builder = SolutionBuilder.new(@notifier)
    #
    @demand1 = Demand.new(:suitor => users(:usery),
                         :departure_place => places(:y1),
                         :arrival_place => places(:y2),
                         :earliest_departure_time => 30.minutes.from_now,
                         :latest_arrival_time => 3.hours.from_now,
                         :expiry_time => 15.minutes.from_now)
    #
    @offering1 = Offering.new(:offerer => users(:useryD),
                             :departure_place => places(:y3),
                             :arrival_place => places(:y4),
                             :departure_time => 1.hour.from_now +
                                30.minutes,
                             :arrival_time => 2.hours.from_now,
                             :expiry_time => 15.minutes.from_now,
                             :seating_capacity => 1,
                             :length => 12000)
    #
    @demand1.default_reply_job_number =
        @notifier.schedule_default_reply_to_demand(@demand1)
    @demand1.save!
    @offering1.save!
  end


  def teardown
    @demand1.destroy
    @offering1.destroy
    @notifier.clear_notifications
  end


  test "builder process demand 1" do
    @builder.build_solutions
    @demand1.reload
    @offering1.reload
    assert @demand1.fulfilled?
    assert @offering1.in_use?
    assert @demand1.fulfilled_demand.valid?
    assert @offering1.used_offering.valid?
    assert_equal @offering1.used_offering,
        @demand1.fulfilled_demand.vehicle_offering
    assert_equal @offering1.seating_capacity - 1,
        @offering1.used_offering.seating_capacity
    #
    assert_equal @offering1.used_offering,
        @demand1.fulfilled_demand.vehicle_offering
    #
    check_the_fulfilled_demand_1
    # check the notifications
    notifications = @notifier.notifications
    assert !notifications.empty?
    assert_equal 1, notifications.size
    assert @notifier.scheduled_notifications.empty?
  end


  test "builder process demand1 with offerings 1 and 2" do
    @offering2 = Offering.new(:offerer => users(:useryD),
                             :departure_place => places(:y1),
                             :arrival_place => places(:y4),
                             :departure_time => 40.minutes.from_now,
                             :arrival_time => 50.minutes.from_now,
                             :expiry_time => 15.minutes.from_now,
                             :seating_capacity => 1,
                             :length => 12000)
    @offering2.save!
    # offering2 fulfills demand1
    @builder.build_solutions
    @offering1.reload
    @offering2.reload
    @demand1.reload
    #
    assert @demand1.fulfilled?
    assert_not_nil @offering2.used_offering
    assert_equal @offering2.used_offering,
        @demand1.fulfilled_demand.vehicle_offering
    assert @offering2.used_offering.valid?
    assert_equal @offering2.seating_capacity - 1,
        @offering2.used_offering.seating_capacity
    check_the_fulfilled_demand_1_with_offering_2
    # check the notifications
    notifications = @notifier.notifications
    assert !notifications.empty?
    assert_equal 1, notifications.size
    assert @notifier.scheduled_notifications.empty?
  end


  test "offering1's driver is in demand1 suitor's black list" do
    @demand1.suitor.drivers_in_black_list << @offering1.offerer
    @builder.build_solutions
    assert !@demand1.fulfilled?
    assert !@offering1.in_use?
    # check the notifications
    notifications = @notifier.notifications
    assert notifications.empty?
    assert_equal 1, @notifier.scheduled_notifications.size
  end


  test "demand1's suitor is in offering1 driver's black list" do
    @offering1.offerer.passengers_in_black_list << @demand1.suitor
    @builder.build_solutions
    assert !@demand1.fulfilled?
    assert !@offering1.in_use?
    # check the notifications
    notifications = @notifier.notifications
    assert notifications.empty?
    assert_equal 1, @notifier.scheduled_notifications.size
  end


  test "offering1's driver is in demand1 suitor's black list BIS" do
    @demand1.suitor.drivers_in_black_list << @offering1.offerer
    @builder.build_solutions
    assert !@demand1.fulfilled?
    assert !@offering1.in_use?
    # check the notifications
    notifications = @notifier.notifications
    assert notifications.empty?
    assert_equal 1, @notifier.scheduled_notifications.size
  end


  test "demand1's suitor is in offering1 driver's black list BIS" do
    @offering1.offerer.passengers_in_black_list << @demand1.suitor
    @builder.build_solutions
    assert !@demand1.fulfilled?
    assert !@offering1.in_use?
    # check the notifications
    notifications = @notifier.notifications
    assert notifications.empty?
    assert_equal 1, @notifier.scheduled_notifications.size
  end


  private

  def check_the_fulfilled_demand_1_with_offering_2
    fd = @demand1.fulfilled_demand
    assert fd.valid?
    assert !fd.has_initial_walk?
    assert fd.has_final_walk?
    assert fd.departure_time >= @demand1.earliest_departure_time
    assert fd.arrival_time <= @demand1.latest_arrival_time
    #
    assert_equal @demand1.departure_place, fd.departure_place
    assert_equal @demand1.arrival_place, fd.arrival_place
    #
    assert_equal edges(:y4_y2_F).travel_duration,
        fd.final_walk_duration
    assert_equal edges(:y4_y2_F).length,
        fd.final_walk_length
  end


  def check_the_fulfilled_demand_1
    @demand1.reload
    fd = @demand1.fulfilled_demand
    assert fd.has_initial_walk?
    assert fd.has_final_walk?
    assert fd.departure_time >= @demand1.earliest_departure_time
    assert fd.arrival_time <= @demand1.latest_arrival_time
    #
    assert_equal @demand1.departure_place, fd.departure_place
    assert_equal @demand1.arrival_place, fd.arrival_place
    assert_equal @offering1.departure_place, fd.car_departure_place
    assert_equal @offering1.arrival_place, fd.car_arrival_place
    #
    assert_equal @offering1.departure_time.to_i, fd.car_departure_time.
        to_i
    assert_equal @offering1.arrival_time.to_i, fd.car_arrival_time.to_i
    assert_equal @offering1.travel_duration, fd.car_travel_duration
    assert_equal @offering1.length, fd.car_length
    #
    assert_equal edges(:y1_y3_F).travel_duration,
        fd.initial_walk_duration
    assert_equal edges(:y4_y2_F).travel_duration,
        fd.final_walk_duration
    assert_equal edges(:y1_y3_F).length,
        fd.initial_walk_length
    assert_equal edges(:y4_y2_F).length,
        fd.final_walk_length
  end


end
