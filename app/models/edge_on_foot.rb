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

class EdgeOnFoot < Edge

  def self.find_all_adjacent_by_departure_place(departure_place,
                                                max_length = nil)
    edges = self.find_all_by_departure_place_id(departure_place.id)
    places_founded = []
    edges.each do |edge|
      places_founded << edge.arrival_place if !max_length or
          edge.length <= max_length
    end
    places_founded
  end


  def self.find_all_adjacent_by_arrival_place(arrival_place,
                                              max_length = nil)
    edges = self.find_all_by_arrival_place_id(arrival_place.id)
    places_founded = []
    edges.each do |edge|
      places_founded << edge.departure_place if !max_length or
          edge.length <= max_length
    end
    places_founded
  end

end
