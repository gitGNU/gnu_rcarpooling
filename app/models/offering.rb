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

class Offering < ActiveRecord::Base

  has_one :used_offering, :dependent => :nullify

  has_one :offering_notification, :dependent => :destroy


  belongs_to :departure_place,
      :foreign_key => "departure_place_id",
      :class_name => "Place"

  belongs_to :arrival_place,
      :foreign_key => "arrival_place_id",
      :class_name => "Place"

  belongs_to :offerer,
      :foreign_key => "offerer_id",
      :class_name => "User"


  validates_presence_of :departure_place, :arrival_place, :offerer,
      :departure_time, :arrival_time, :expiry_time


  validates_numericality_of :length, :only_integer => true,
      :greater_than => 0


  validates_numericality_of :seating_capacity,
      :only_integer => true, :greater_than => 0


  validates_length_of :note, :allow_nil => true, :maximum => 500


  validate_on_create :departure_time_must_be_later_than_10_minutes_from_now,
      :expiry_time_must_be_later_than_5_minutes_from_now, :times_compatible


  validate :expiry_time_must_be_earlier_than_or_equal_to_departure_time,
      :expiry_time_must_be_later_than_or_equal_to_2_hours_before_departure_time,
      :arrival_place_must_be_distinct_from_departure_place,
      :arrival_time_must_be_later_than_departure_time,
      :clean_note


  def travel_duration
    ((arrival_time - departure_time)/60).to_i
  end


  def chilled?
    Time.now >= chilled_since
  end


  def chilled_since
    departure_time - 2.hours
  end


  def in_use?
    used_offering && true
  end


  def expired?
    Time.now >= expiry_time
  end


  def self.intersects_any?(offerer_id, departure_time, arrival_time)
    l = departure_time
    r = arrival_time
    unless l <= r
      raise Exception.new
    end
    Offering.find(:first,
        :conditions => ["offerer_id = ? and ((departure_time >= ? and " +
                        "departure_time <= ?) or (arrival_time >= ? and " +
                        "arrival_time <= ?) or (departure_time <= ? and " +
                        "arrival_time >= ?) or (departure_time >= ? and " +
                        "arrival_time <= ?))", offerer_id, l, r, l, r,
                        l, r, l, r]) && true || false
  end


  private


  def expiry_time_must_be_earlier_than_or_equal_to_departure_time
    if expiry_time and departure_time
      unless expiry_time <= departure_time
        errors.add(:expiry_time, I18n.t("activerecord.errors.messages." +
                                        "offering.expiry_time_must_be_" +
                                       "earlier_than_or_equal_to_" +
                                       "departure_time"))
      end
    end
  end


  def departure_time_must_be_later_than_10_minutes_from_now
    if departure_time and ! (departure_time > 10.minutes.from_now)
      errors.add(:departure_time, I18n.t("activerecord.errors.messages." +
                                         "offering.departure_time_must_be_" +
                                        "later_than_10_minutes_from_now"))
    end
  end


  def expiry_time_must_be_later_than_5_minutes_from_now
    if expiry_time and ! (expiry_time > 5.minutes.from_now)
      errors.add(:expiry_time, I18n.t("activerecord.errors.messages.offering." +
                                      "expiry_time_must_be_later_than_5_minutes_from_now"))
    end
  end


  def expiry_time_must_be_later_than_or_equal_to_2_hours_before_departure_time
    if expiry_time and departure_time
      unless expiry_time >= (departure_time - 2.hours)
        errors.add(:expiry_time, I18n.t("activerecord.errors.messages.offering." +
                                        "expiry_time_must_be_later_than_" +
                                       "or_equal_to_2_hours_before_departure_time"))
      end
    end
  end


  def arrival_place_must_be_distinct_from_departure_place
    if arrival_place and departure_place
      unless arrival_place != departure_place
        errors.add(:arrival_place, I18n.t("activerecord.errors.messages." +
                                          "offering.arrival_place_must_be_" +
                                         "distinct_from_departure_place"))
      end
    end
  end


  def arrival_time_must_be_later_than_departure_time
    if departure_time and arrival_time and arrival_time <= departure_time
      errors.add(:arrival_time, I18n.t("activerecord.errors.messages." +
                                       "offering.arrival_time_must_be_" +
                                      "later_than_departure_time"))
    end
  end


  def clean_note
    if note
      self.note.strip!
      self.note = nil if note.empty?
    end
  end


  def times_compatible
    if departure_time and arrival_time and (offerer or offerer_id)
      uid = offerer_id || offerer.id
      d = departure_time; a = arrival_time
      if Demand.intersects_any?(uid, d, a) or
          Offering.intersects_any?(uid, d, a)
        errors.add(:departure_time, I18n.t('activerecord.errors.' +
                                            'messages.offering.' +
                                            'time_incompatible'))
        errors.add(:arrival_time, I18n.t('activerecord.errors.' +
                                                'messages.offering.' +
                                                'time_incompatible'))
      end
    end
  end

end
