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

class BlackListDriversEntry < ActiveRecord::Base

  belongs_to :user


  belongs_to :driver,
      :foreign_key => "driver_id",
      :class_name => "User"


  validates_presence_of :user, :driver


  validate :driver_must_be_distinct_from_user


  private


  def driver_must_be_distinct_from_user
    if user and driver and driver == user
      errors.add(:driver, "must be distinct from user")
    end
  end
end
