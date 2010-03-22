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


class OfferingProcessor


  def initialize(notifier)
    @notifier = notifier
  end


  # schedule the "list of passengers" notification for
  # offering.expiry_time
  def process_incoming_offering(offering)
    offering.passengers_list_job_number =
        @notifier.schedule_passengers_list(offering)
    offering.save
  end


  # cancel the "at" job scheduled to notify the passengers
  # list to the driver
  def revoke_offering(offering)
    job_number = offering.passengers_list_job_number
    @notifier.remove_scheduled_notification(job_number)
    offering.passengers_list_job_number = nil
    offering.save
  end


  # 1 find all the demands fulfilled by this offering
  # 2 notify each demand's suitor with
  #   Notifier#notify_demand_no_longer_fulfilled
  # 3 delete each fulfilled_demand this offering fulfills
  def revoke_used_offering(used_offering)
    fulfilled_demands = FulfilledDemand.
      find_all_fulfilled_by_a_used_offering(used_offering)
    fulfilled_demands.each do |fd|
      @notifier.notify_demand_no_longer_fulfilled(fd)
      fd.destroy
    end # loop
  end

end
