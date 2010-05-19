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

class NotificationMailerTest < ActionMailer::TestCase


  def setup
    @languages = []
    Language.find(:all).each { |l| @languages << l.name }
  end


  def tear_down
    @languages.clear
  end


  test "notify fulfilled demand" do
    fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_1)
    user = fulfilled_demand.suitor
    subject = "bla bla bla"
    from = "foo@bar"
    @languages.each do |lang|
      email = NotificationMailer.create_notify_fulfilled_demand(
        fulfilled_demand, user, lang, subject, from)
      assert_equal user.email, email.to[0]
      assert_equal subject, email.subject
      assert_equal from, email.from[0]
    end
  end


  test "notify demand no longer fulfilled" do
    fulfilled_demand = fulfilled_demands(:fulfilled_demand_n_1)
    user = fulfilled_demand.suitor
    subject = "bla bla bla"
    from = "foo@bar"
    @languages.each do |lang|
      email = NotificationMailer.
        create_notify_demand_no_longer_fulfilled(fulfilled_demand,
                                                 user, lang,
                                                 subject, from)
      assert_equal user.email, email.to[0]
      assert_equal subject, email.subject
      assert_equal from, email.from[0]
    end
  end


  test "default reply for a demand" do
    demand = demands(:mickey_mouse_demand_n_1)
    subject = "bla bli blu"
    from = "bla@bli"
    @languages.each do |lang|
      email = NotificationMailer.create_no_solution_for_a_demand(
        demand, lang, subject, from)
      assert_equal demand.suitor.email, email.to[0]
      assert_equal subject, email.subject
      assert_equal from, email.from[0]
    end
  end


  test "passengers list" do
    offering = offerings(:donald_duck_offering_n_1)
    assert offering.in_use? # offering must be in use
    subject = "qwerty"
    from = "a@b"
    @languages.each do |lang|
      email = NotificationMailer.create_passengers_list(
        offering, lang, subject, from)
      assert_equal offering.offerer.email, email.to[0]
      assert_equal subject, email.subject
      assert_equal from, email.from[0]
    end
  end


  test "passengers list of unused offering" do
    offering = offerings(:mickey_mouse_offering_n_1)
    assert !offering.in_use? # offering must be unused
    subject = "qwerty"
    from = "a@b"
    @languages.each do |lang|
      email = NotificationMailer.create_passengers_list(
        offering, lang, subject, from)
      assert_equal offering.offerer.email, email.to[0]
      assert_equal subject, email.subject
      assert_equal from, email.from[0]
    end
  end

end
