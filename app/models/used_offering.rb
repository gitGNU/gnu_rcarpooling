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

class UsedOffering < ActiveRecord::Base

  belongs_to :offering


  validates_presence_of :offering


  validates_numericality_of :seating_capacity, :only_integer => true,
      :greater_than_or_equal_to => 0


  def grab_seating!
    self.seating_capacity = seating_capacity - 1
    save!
  end


  def release_seating!
    self.seating_capacity = seating_capacity + 1
    save!
  end


  def has_empty_seating?
    seating_capacity > 0
  end


  def chilled?
    offering.chilled?
  end


  def length
    offering.length
  end


  def travel_duration
    offering.travel_duration
  end


  def departure_time
    offering.departure_time
  end


  def arrival_time
    offering.arrival_time
  end


  def expiry_time
    offering.expiry_time
  end


  def departure_place
    offering.departure_place
  end


  def arrival_place
    offering.arrival_place
  end


  def driver
    offering.offerer
  end


  def offerer
    driver
  end


  def passengers
    FulfilledDemand.find_all_fulfilled_by_a_used_offering(
      self).map { |fd| fd.suitor }
  end


  def chilled_since
    offering.chilled_since
  end


  def expired?
    offering.expired?
  end


  def note
    offering.note
  end


  def offering_notification
    offering.offering_notification
  end

end
