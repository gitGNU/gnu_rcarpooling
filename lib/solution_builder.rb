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

class SolutionBuilder

  def initialize(notifier)
    @notifier = notifier
  end


  # used by ruby script/runner and (probably) launched from a cron
  # job
  def self.run
    builder = self.new(Notifier.new)
    builder.build_solutions
  end


  def build_solutions
    demands = Demand.find_all_not_fulfilled_and_not_expired
    demands.each do |demand|
      compatible_offerings = find_all_offerings_compatibles_with(demand)
      compatible_offerings.each do |offering|
        used_offering = offering.used_offering
        if used_offering
          next if !used_offering.has_empty_seating?
        else
          uo_factory = UsedOfferingFactory.new(offering)
          used_offering = uo_factory.build_used_offering
          used_offering.save!
        end
        used_offering.grab_seating!
        #
        first_walk_departure_time = nil
        first_walk_duration = nil
        first_walk_length = nil
        second_walk_departure_time = nil
        second_walk_duration = nil
        second_walk_length = nil
        # the first walk
        if demand.departure_place != offering.departure_place
          edge_on_foot = EdgeOnFoot.
            find_by_departure_place_id_and_arrival_place_id(
              demand.departure_place.id, offering.departure_place.id)
          first_walk_duration = edge_on_foot.travel_duration
          first_walk_departure_time = offering.departure_time -
              first_walk_duration.minutes
          first_walk_length = edge_on_foot.length
        end
        # the second walk
        if demand.arrival_place != offering.arrival_place
          edge_on_foot = EdgeOnFoot.
            find_by_departure_place_id_and_arrival_place_id(
              offering.arrival_place.id, demand.arrival_place.id)
          second_walk_duration = edge_on_foot.travel_duration
          second_walk_departure_time = offering.arrival_time
          second_walk_length = edge_on_foot.length
        end
        #
        # ready to fulfill the demand :)
        fd_factory =
            FulfilledDemandFactory.new(demand, used_offering,
                                       demand.departure_place,
                                       first_walk_departure_time,
                                       first_walk_duration,
                                       first_walk_length,
                                       offering.departure_place,
                                       offering.arrival_place,
                                       demand.arrival_place,
                                       second_walk_departure_time,
                                       second_walk_duration,
                                       second_walk_length)
        fulfilled_demand = fd_factory.build_fulfilled_demand
        fulfilled_demand.save!
        #
        # begin notification handling
        # cancel default reply scheduled
        @notifier.remove_scheduled_notification(
          demand.default_reply_job_number)
        demand.default_reply_job_number = nil
        demand.save!
        # send the notification "demand is fulfilled"
        @notifier.notify_fulfilled_demand(fulfilled_demand)
        # end of notification handling
        #
        break # process the next DEMAND
      end # loop on compatible offerings
    end # loop on demands
  end # method build_solutions


  private


  # returns an array of all offerings compatibles with the demand
  # specified. They are instances of class Offering and
  # the client must check the seating capacity.
  # All the offerings returned are not expired at
  # the time of call (you had better re-check).
  # The departure/arrival times are ok, checked against edges on foot
  # too.
  # Blacklists checked
  def find_all_offerings_compatibles_with(demand)
    offerings_founded = []
    places_near_demand_departure_p =
        EdgeOnFoot.find_all_adjacent_by_departure_place(
          demand.departure_place, demand.suitor.max_foot_length)
    places_near_demand_arrival_p =
        EdgeOnFoot.find_all_adjacent_by_arrival_place(
          demand.arrival_place, demand.suitor.max_foot_length)
    places_near_demand_departure_p.insert(0, demand.departure_place)
    places_near_demand_arrival_p.insert(0, demand.arrival_place)
    #
    places_near_demand_departure_p.each do |departure_place|
      places_near_demand_arrival_p.each do |arrival_place|
        offerings = Offering.
              find_all_by_departure_place_id_and_arrival_place_id(
                departure_place.id, arrival_place.id)
        #
        offerings.each do |offering|
          if !offering.expired? and offering.departure_time >=
              demand.earliest_departure_time and
              offering.arrival_time <= demand.latest_arrival_time
            # first walk check
            if offering.departure_place != demand.departure_place
              edge_on_foot = EdgeOnFoot.
                  find_by_departure_place_id_and_arrival_place_id(
                    demand.departure_place.id,
                    offering.departure_place.id)
              if (offering.departure_time -
                    edge_on_foot.travel_duration.minutes) <
                 demand.earliest_departure_time
                next
              end
            end
            # second walk check
            if offering.arrival_place != demand.arrival_place
              edge_on_foot = EdgeOnFoot.
                find_by_departure_place_id_and_arrival_place_id(
                  offering.arrival_place.id, demand.arrival_place.id)
              if (offering.arrival_time +
                  edge_on_foot.travel_duration.minutes) >
                 demand.latest_arrival_time
                next
              end
            end
            # black list check
            if offering.offerer.passengers_in_black_list.include?(
              demand.suitor) or
              demand.suitor.drivers_in_black_list.include?(
                offering.offerer)
                next
            end
            offerings_founded << offering
          end
        end # offerings loop
      end
    end
    offerings_founded
  end

end
