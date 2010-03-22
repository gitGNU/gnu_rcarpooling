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

class OldSolutionBuilder

  def initialize(notifier)
    @notifier = notifier
  end


  def process_demand(demand)
    process_demand_priv(demand)
  end


  def process_offering(offering)
    process_offering_priv(offering)
  end


  private


  def process_demand_priv(demand)
    departure_set = EdgeOnFoot.find_all_adjacent_by_departure_place(
      demand.departure_place)
    arrival_set = EdgeOnFoot.find_all_adjacent_by_arrival_place(
      demand.arrival_place)
    departure_set.insert(0, demand.departure_place)
    arrival_set.insert(0, demand.arrival_place)
    Offering.transaction do
      offerings = []
      departure_set.each do |dep_place|
        arrival_set.each do |arr_place|
          offerings.concat Offering.find(:all, :lock => true,
            :conditions => [ "departure_place_id = ? " +
                  "and arrival_place_id = ? " +
                  "and departure_time >= ? and arrival_time <= ? " +
                  "and expiry_time > ?",
                  dep_place.id,
                  arr_place.id,
                  demand.earliest_departure_time,
                  demand.latest_arrival_time,
                  2.minutes.from_now])

        end # internal loop
      end # external loop
      demand.lock!
      if demand.fulfilled?
        return
      end
      offerings.each do |offering|
        # check if this offering is suitable for that demand
        # offering is incompatible if offering.driver is in the
        # demand.suitor blacklist or if demand.suitor is in the
        # black list of offering.driver
        if demand.suitor.drivers_in_black_list.include?(offering.offerer) or
            offering.offerer.passengers_in_black_list.include?(demand.suitor)
          next
        end
        # travel times are compatible?
        if demand.departure_place != offering.departure_place
          edge = EdgeOnFoot.find_by_departure_place_id_and_arrival_place_id(
            demand.departure_place.id, offering.departure_place.id)
          travel_duration = edge.travel_duration
          unless demand.earliest_departure_time <=
              (offering.departure_time - travel_duration.minutes)
            next
          end
        end
        if demand.arrival_place != offering.arrival_place
          edge = EdgeOnFoot.find_by_departure_place_id_and_arrival_place_id(
            offering.arrival_place.id, demand.arrival_place.id)
          travel_duration = edge.travel_duration
          unless demand.latest_arrival_time >= (offering.arrival_time +
                                                travel_duration.minutes)
            next
          end
        end
        # ok, now I am sure this offering is compatible
        used_offering = nil
        if offering.in_use? # this offering is already in use
          used_offering = offering.used_offering
        else # this offering isn't in use yet
          factory = UsedOfferingFactory.new(offering)
          used_offering = factory.build_used_offering
          offering.used_offering = used_offering
          offering.save!
        end
        used_offering.lock!
        if used_offering.has_empty_seating?
          # now I can build the solution :)
          used_offering.grab_seating!
          #
          travel_duration1 = 0; length1 = 0
          travel_duration2 = 0; length2 = 0
          if demand.departure_place != used_offering.departure_place
            edge = EdgeOnFoot.
              find_by_departure_place_id_and_arrival_place_id(
                demand.departure_place.id, used_offering.departure_place.id)
            travel_duration1 = edge.travel_duration
            length1 = edge.length
          end
          if demand.arrival_place != used_offering.arrival_place
            edge = EdgeOnFoot.
              find_by_departure_place_id_and_arrival_place_id(
                used_offering.arrival_place.id, demand.arrival_place.id)
            travel_duration2 = edge.travel_duration
            length2 = edge.length
          end
          ##
          factory = FulfilledDemandFactory.new(
              demand, used_offering,
              demand.departure_place,
              used_offering.departure_time - travel_duration1.minutes,
              travel_duration1, length1,
              used_offering.departure_place,
              used_offering.arrival_place,
              demand.arrival_place,
              used_offering.arrival_time,
              travel_duration2, length2)
          ##
          demand.fulfilled_demand = factory.build_fulfilled_demand
          demand.save!
          # notify demand's suitor
          notify_demand_suitor(demand.fulfilled_demand)
          break # I have found a solution, that's all
        end
      end # loop
    end # transaction
  end





  def process_offering_priv(offering)
    departure_set = EdgeOnFoot.find_all_adjacent_by_arrival_place(
      offering.departure_place)
    arrival_set = EdgeOnFoot.find_all_adjacent_by_departure_place(
      offering.arrival_place)
    departure_set.insert(0, offering.departure_place)
    arrival_set.insert(0, offering.arrival_place)
    Demand.transaction do
      offering.lock!
      demands = []
      departure_set.each do |dep_place|
        arrival_set.each do |arr_place|
          demands.concat Demand.find(:all, :lock => true,
                :conditions => [ "departure_place_id = ? " +
                                 "and arrival_place_id = ? " +
                                 "and earliest_departure_time <= ? " +
                                 "and latest_arrival_time >= ? " +
                                 "and expiry_time > ?",
                                  dep_place.id,
                                  arr_place.id,
                                  offering.departure_time,
                                  offering.arrival_time,
                                  2.minutes.from_now])

        end # internal loop
      end # external loop
      demands.each do |demand|
        # check if this demand is suitable for that offering
        # offering is incompatible if offering.driver is in the
        # demand.suitor blacklist or if demand.suitor is in the
        # black list of offering.driver
        if demand.suitor.drivers_in_black_list.include?(offering.offerer) or
            offering.offerer.passengers_in_black_list.include?(demand.suitor)
          next
        end
        # travel times are compatible?
        if demand.departure_place != offering.departure_place
          edge = EdgeOnFoot.find_by_departure_place_id_and_arrival_place_id(
            demand.departure_place.id, offering.departure_place.id)
          travel_duration = edge.travel_duration
          unless demand.earliest_departure_time <=
              (offering.departure_time - travel_duration.minutes)
            next
          end
        end
        if demand.arrival_place != offering.arrival_place
          edge = EdgeOnFoot.find_by_departure_place_id_and_arrival_place_id(
            offering.arrival_place.id, demand.arrival_place.id)
          travel_duration = edge.travel_duration
          unless demand.latest_arrival_time >=
              (offering.arrival_time + travel_duration.minutes)
            next
          end
        end
        # ok, now I am sure this demand is compatible
        used_offering = nil
        if offering.in_use? # this offering is already in use
          used_offering = offering.used_offering
        else # this offering isn't in use yet
          factory = UsedOfferingFactory.new(offering)
          used_offering = factory.build_used_offering
          offering.used_offering = used_offering
          offering.save!
        end
        used_offering.lock!
        unless used_offering.has_empty_seating?
          break # that's all, I have used all the seating
        end
        unless demand.fulfilled?
          # now I can build the solution :)
          used_offering.grab_seating!
          #
          travel_duration1 = 0; length1 = 0
          travel_duration2 = 0; length2 = 0
          if demand.departure_place != used_offering.departure_place
            edge = EdgeOnFoot.
              find_by_departure_place_id_and_arrival_place_id(
                demand.departure_place.id, used_offering.departure_place.id)
            travel_duration1 = edge.travel_duration
            length1 = edge.length
          end
          if demand.arrival_place != used_offering.arrival_place
            edge = EdgeOnFoot.
              find_by_departure_place_id_and_arrival_place_id(
                used_offering.arrival_place.id, demand.arrival_place.id)
            travel_duration2 = edge.travel_duration
            length2 = edge.length
          end
          ##
          factory = FulfilledDemandFactory.new(
              demand, used_offering,
              demand.departure_place,
              used_offering.departure_time - travel_duration1.minutes,
              travel_duration1, length1,
              used_offering.departure_place,
              used_offering.arrival_place,
              demand.arrival_place,
              used_offering.arrival_time,
              travel_duration2, length2)
          ##
          demand.fulfilled_demand = factory.build_fulfilled_demand
          demand.save!
          # notification to demand's suitor
          notify_demand_suitor(demand.fulfilled_demand)
        end
      end # loop
    end # transaction
  end


  def notify_demand_suitor(fulfilled_demand)
    @notifier.notify_fulfilled_demand(fulfilled_demand)
  end

end
