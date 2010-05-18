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

class NotificationTest < ActiveSupport::TestCase

  test "valid notification" do
    n = Notification.new :recipient => users(:donald_duck)
    assert n.valid?
    assert n.save
  end


  test "notification invalid with empty fields" do
    n = Notification.new
    assert ! n.valid?
    assert n.errors.invalid?(:recipient)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        n.errors.on(:recipient)
  end


  test "valid demand notification" do
    demand = demands(:mickey_mouse_demand_n_1)
    n = DemandNotification.new :demand => demand,
        :recipient => demand.suitor
    # default value for "seen"
    assert !n.seen
    #
    assert n.valid?
    assert n.save
  end


  test "demand notification invalid with empty fields" do
    n = DemandNotification.new
    assert ! n.valid?
    assert n.errors.invalid?(:demand)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        n.errors.on(:demand)
  end


  test "demand suitor is the recipient" do
    n = DemandNotification.new(:recipient => users(:donald_duck),
                               :demand => demands(:mickey_mouse_demand_n_1))
    assert ! n.valid?
    assert n.errors.invalid?(:demand)
    assert_equal I18n.t('activerecord.errors.messages.demand_notification.' +
                        'suitor_must_be_the_recipient'),
                        n.errors.on(:demand)
  end


  test "valid offering notification" do
    offering = offerings(:donald_duck_offering_n_1)
    n = OfferingNotification.new(:recipient => offering.offerer,
      :offering => offering)
    # default value for "seen"
    assert !n.seen
    #
    assert n.valid?
    assert n.save
  end


  test "offering notification invalid with empty fields" do
    n = OfferingNotification.new
    assert ! n.valid?
    assert n.errors.invalid?(:offering)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        n.errors.on(:offering)
  end


  test "offering offerer is the recipient" do
    o = OfferingNotification.new(:recipient => users(:donald_duck),
                      :offering => offerings(:mickey_mouse_offering_n_1))
    assert !o.valid?
    assert o.errors.invalid?(:offering)
    assert_equal I18n.t('activerecord.errors.messages.' +
                        'offering_notification.' +
                        'offerer_must_be_the_recipient'),
                        o.errors.on(:offering)
  end


end
