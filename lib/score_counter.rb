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

class ScoreCounter

  def self.count_scores
    users = User.find :all
    users.each do |user|
      score = 0
      # iterate over users's offerings
      user.offerings.each do |offering|
        if offering.chilled? and offering.in_use?
          used_offering = offering.used_offering
          score += used_offering.passengers.size *
              (used_offering.length / 1000)
        end
      end # offerings.each
      # iterate over user's demands
      user.demands.each do |demand|
        if demand.chilled? and demand.fulfilled?
          fd = demand.fulfilled_demand
          score -= fd.car_length / 1000
        end
      end # demands.each
      # save score
      user.score = score
      user.save!
    end # users.each
  end

end
