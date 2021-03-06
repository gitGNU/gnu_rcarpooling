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

class DemandNotification < Notification

  belongs_to :demand


  validates_presence_of :demand

  validate :suitor_must_be_the_recipient


  def user
    demand && demand.suitor
  end

  private

  def suitor_must_be_the_recipient
    if demand and recipient
      unless demand.suitor == recipient
        errors.add(:demand, I18n.t('activerecord.errors.messages.' +
            'demand_notification.suitor_must_be_the_recipient'))
      end
    end
  end

end
