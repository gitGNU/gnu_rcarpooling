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

class NotifierMock # MOCK


  def initialize
    @notifications = []
    @scheduled_notifications = []
  end


  attr_reader :notifications, :scheduled_notifications


  # notifies user that his/her demand has been fulfilled :)
  def notify_fulfilled_demand(fulfilled_demand)
    @notifications << "demand #{fulfilled_demand.demand.id} has " +
        "been fulfilled"
  end


  # revokes a travel solution previously notified :(
  # it is caused by a driver's revoking
  def notify_demand_no_longer_fulfilled(fulfilled_demand)
    @notifications << "fulfilled demand #{fulfilled_demand.id} is no " +
        "longer available"
  end


  def clear_notifications
    @notifications.clear
  end


  # default reply to a demand: no solution. Scheduled at
  # demand.expiry_time
  def schedule_default_reply_to_demand(demand)
    @scheduled_notifications << "sorry, no solution for demand " +
        "#{demand.id} " +
        "this notification should be sent at #{demand.expiry_time}"
    @scheduled_notifications.size - 1
  end


  def schedule_passengers_list(offering)
    @scheduled_notifications << "passengers list for offering " +
        "#{offering.id} this notification should be sent at " +
        "#{offering.expiry_time}"
    @scheduled_notifications.size - 1
  end


  def remove_scheduled_notification(job_number)
    @scheduled_notifications.delete_at(job_number)
  end

end
