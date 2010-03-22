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

class Segment < ActiveRecord::Base

  belongs_to :fulfilled_demand,
      :foreign_key => "fulfilled_demand_id",
      :class_name => "FulfilledDemand"


  validates_presence_of :fulfilled_demand


  validates_numericality_of :order_number, :only_integer => true,
      :greater_than => 0
end
