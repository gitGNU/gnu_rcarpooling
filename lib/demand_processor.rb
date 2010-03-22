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

class DemandProcessor


  def initialize(notifier)
    @notifier = notifier
  end


  # schedule the "no solutions found" notification
  def process_incoming_demand(demand)
    demand.default_reply_job_number =
        @notifier.schedule_default_reply_to_demand(demand)
    demand.save!
  end


  # cancel the notification job scheduled
  def revoke_demand(demand)
    job_number = demand.default_reply_job_number
    if job_number
      @notifier.remove_scheduled_notification(job_number)
      demand.default_reply_job_number = nil
      demand.save!
    end
  end


  # 1 Eventually, notify the car driver that will be there a passenger
  #   less
  # 2 Call UsedOffering#release_seating!
  # 3 Eventually delete the used_offering
  #   (if it was the only passenger)
  def revoke_fulfilled_demand(fulfilled_demand)
    UsedOffering.transaction do
      used_offering = fulfilled_demand.used_offering
      used_offering.lock!
      offering = used_offering.offering
      array = FulfilledDemand.find_all_fulfilled_by_a_used_offering(
        used_offering)
      if array.size == 1
        # I'm the only fulfilled_demand that uses this used_offering
        # so I can delete it
        used_offering.destroy
      else
        # otherwise, only release my seating
        used_offering.release_seating!
      end
    end # transaction
  end

end
