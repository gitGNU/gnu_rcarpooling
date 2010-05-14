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

class Demand < ActiveRecord::Base

  has_one :fulfilled_demand, :dependent => :nullify


  has_many :demand_notifications, :dependent => :destroy


  belongs_to :suitor,
      :foreign_key => "suitor_id",
      :class_name => "User"


  belongs_to :departure_place,
      :foreign_key => "departure_place_id",
      :class_name => "Place"


  belongs_to :arrival_place,
      :foreign_key => "arrival_place_id",
      :class_name => "Place"



  validates_presence_of :suitor, :departure_place, :arrival_place,
      :earliest_departure_time, :latest_arrival_time, :expiry_time


  validate :latest_arrival_time_must_be_later_than_earliest_departure_time,
      :expiry_time_must_be_earlier_than_or_equal_to_earliest_departure_time,
      :arrival_place_must_be_distinct_from_departure_place


  validate_on_create :expiry_time_must_be_later_than_5_minutes_from_now,
      :earliest_departure_time_must_be_later_than_10_minutes_from_now,
      :times_compatible



  def chilled?
    fulfilled_demand && fulfilled_demand.chilled?
  end


  def fulfilled?
    fulfilled_demand && true
  end


  def expired?
    Time.now >= expiry_time
  end


  def deletable?
    if fulfilled?
      fulfilled_demand.deletable?
    else
      !expired?
    end
  end


  def self.find_all_not_fulfilled_and_not_expired
    result_set = []
    self.find(:all).each do |demand|
      result_set << demand if !demand.expired? and !demand.fulfilled?
    end
    result_set
  end


  def self.intersects_any?(suitor_id, earliest_departure_time,
                           latest_arrival_time)
    l = earliest_departure_time
    r = latest_arrival_time
    unless l <= r
      raise Exception.new
    end
    Demand.find(:first,
        :conditions => ["suitor_id = ? and " +
                        "((earliest_departure_time >= ? and " +
                        "earliest_departure_time <= ?) or " +
                        "(latest_arrival_time >= ? and " +
                        "latest_arrival_time <= ?) or " +
                        "(earliest_departure_time <= ? and " +
                        "latest_arrival_time >= ?) or " +
                        "(earliest_departure_time >= ? and " +
                        "latest_arrival_time <= ?))", suitor_id,
                        l, r, l, r, l, r, l, r]) && true || false
  end


  private


  def latest_arrival_time_must_be_later_than_earliest_departure_time
    if latest_arrival_time and earliest_departure_time
      unless latest_arrival_time > earliest_departure_time
        errors.add(:latest_arrival_time, I18n.t("activerecord.errors." +
                                                "messages.demand." +
                                               "latest_arrival_time_" +
                                               "must_be_later_than_" +
                                               "earliest_departure_time"))
      end
    end
  end


  def earliest_departure_time_must_be_later_than_10_minutes_from_now
    if earliest_departure_time and !(earliest_departure_time >
                                     10.minutes.from_now)
      errors.add(:earliest_departure_time, I18n.t("activerecord.errors." +
                                                  "messages.demand." +
                                                 "earliest_departure_" +
                                                 "time_must_be_later_than" +
                                                 "_10_minutes_from_now"))
    end
  end


  def expiry_time_must_be_earlier_than_or_equal_to_earliest_departure_time
    if expiry_time and earliest_departure_time
      unless expiry_time <= earliest_departure_time
        errors.add(:expiry_time, I18n.t("activerecord.errors.messages." +
                                        "demand.expiry_time_must_be_" +
                                       "earlier_than_or_equal_to_" +
                                       "earliest_departure_time"))
      end
    end
  end


  def expiry_time_must_be_later_than_5_minutes_from_now
    if expiry_time and !(expiry_time > 5.minutes.from_now)
      errors.add(:expiry_time, I18n.t("activerecord.errors.messages." +
                                      "demand.expiry_time_must_be_later" +
                                     "_than_5_minutes_from_now"))
    end
  end


  def arrival_place_must_be_distinct_from_departure_place
    if arrival_place and departure_place and departure_place == arrival_place
      errors.add(:arrival_place, I18n.t("activerecord.errors.messages.demand." +
                        "arrival_place_must_be_distinct_from_departure_place"))
    end
  end


  def times_compatible
    if earliest_departure_time and latest_arrival_time and
        (suitor or suitor_id)
      uid = suitor_id || suitor.id
      e = earliest_departure_time; l = latest_arrival_time
      if Demand.intersects_any?(uid, e, l) or
          Offering.intersects_any?(uid, e, l)
        errors.add(:earliest_departure_time, I18n.t('activerecord.errors.' +
                                                    'messages.demand.' +
                                                    'time_incompatible'))
        errors.add(:latest_arrival_time, I18n.t('activerecord.errors.' +
                                                    'messages.demand.' +
                                                    'time_incompatible'))
      end
    end
  end

end
