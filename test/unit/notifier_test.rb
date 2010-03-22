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

class NotifierTest < ActiveSupport::TestCase

  def setup
    @emails = ActionMailer::Base.deliveries
    @emails.clear
  end


  test "notify fulfilled demand" do
    fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_1)
    Notifier.new.notify_fulfilled_demand(fulfilled_demand)
    assert !@emails.empty?
    assert_equal 1, @emails.size
    assert_equal fulfilled_demand.suitor.email,
        @emails[0].to[0]
  end


  test "notify fulfilled demand is no longer available" do
    fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_1)
    Notifier.new.notify_demand_no_longer_fulfilled(fulfilled_demand)
    assert !@emails.empty?
    assert_equal 1, @emails.size
    assert_equal fulfilled_demand.suitor.email,
        @emails[0].to[0]
  end


  test "static method send default reply for a demand" do
    demand = demands(:mickey_mouse_demand_n_1)
    Notifier.send_default_reply_for_a_demand(demand.id)
    assert !@emails.empty?
    assert_equal 1, @emails.size
    assert_equal demand.suitor.email, @emails[0].to[0]
  end


  # this test checks "at" jobs
  test "schedule default reply to a demand" do
    # check "at" queue
    n_jobs = `atq | wc -l`
    n_jobs = n_jobs.chomp
    if 0 != n_jobs.to_i
      raise Exception.new("there are some -at- jobs")
    end
    #
    demand = demands(:mickey_mouse_demand_n_1)
    demand.expiry_time = 10.minutes.from_now
    job_number = Notifier.new.schedule_default_reply_to_demand(demand)
    job_number_string = `atq | cut -f 1`
    job_number_string = job_number_string.chomp
    # safety check
    if job_number_string.to_i != job_number
      raise Exception.new("WARNING, CHECK at QUEUE")
    end
    #
    assert_equal job_number, job_number_string.to_i
    # remove the job scheduled :P
    `atrm #{job_number}`
  end


  test "static method send passengers list" do
    offering = offerings(:donald_duck_offering_n_1)
    Notifier.send_passengers_list(offering.id)
    assert !@emails.empty?
    assert_equal 1, @emails.size
    assert_equal offering.offerer.email, @emails[0].to[0]
  end


  # this test checks "at" jobs
  test "schedule list of passengers notification" do
    # check "at" queue
    n_jobs = `atq | wc -l`
    n_jobs = n_jobs.chomp
    if 0 != n_jobs.to_i
      raise Exception.new("there are some -at- jobs")
    end
    #
    offering = offerings(:donald_duck_offering_n_1)
    offering.expiry_time = 10.minutes.from_now
    job_number = Notifier.new.schedule_passengers_list(offering)
    job_number_string = `atq | cut -f 1`
    job_number_string = job_number_string.chomp
    # safety check
    if job_number_string.to_i != job_number
      raise Exception.new("WARNING, CHECK at QUEUE")
    end
    #
    assert_equal job_number, job_number_string.to_i
    # remove the job scheduled :P
    `atrm #{job_number}`
  end


  test "remove scheduled notification" do
    # check "at" queue
    n_jobs = `atq | wc -l`
    n_jobs = n_jobs.chomp
    if 0 != n_jobs.to_i
      raise Exception.new("there are some -at- jobs")
    end
    #
    # create a fake "at" job
    job_number_string = `echo 'echo blablabla' | \
        at now + 30 minutes 2>&1 | tail -n 1 | cut -d ' ' -f 2`
    job_number_string = job_number_string.chomp
    #
    Notifier.new.remove_scheduled_notification(job_number_string.to_i)
    #
    n_jobs = `atq | wc -l`
    n_jobs = n_jobs.chomp
    if 0 != n_jobs.to_i
      raise Exception.new("WARNING, CHECK at QUEUE")
    end
    assert_equal 0, n_jobs.to_i
  end


end
