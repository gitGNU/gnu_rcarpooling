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
fd = @fulfilled_demand
xml.fulfilled_demand(:id => fd.id, :href => fulfilled_demand_url(fd)) do
  xml.demand(:id => fd.demand.id, :href => demand_url(fd.demand))
  xml.suitor(:id => fd.suitor.id, :href => user_url(fd.suitor))
  xml.departure_place(:id => fd.departure_place.id,
    :href => place_url(fd.departure_place))
  xml.arrival_place(:id => fd.arrival_place.id,
    :href => place_url(fd.arrival_place))
  xml.departure_time(fd.departure_time.xmlschema)
  xml.arrival_time(fd.arrival_time.xmlschema)
  xml.guaranteed_since(fd.guaranteed_since.xmlschema)
  xml.car do
    xml.offering(:id => fd.vehicle_offering.id,
                 :href => used_offering_url(fd.vehicle_offering))
    xml.departure_place(:id => fd.car_departure_place.id,
      :href => place_url(fd.car_departure_place))
    xml.arrival_place(:id => fd.car_arrival_place.id,
      :href => place_url(fd.car_arrival_place))
    xml.departure_time(fd.car_departure_time.xmlschema)
    xml.arrival_time(fd.car_arrival_time.xmlschema)
    xml.travel_duration(fd.car_travel_duration)
    xml.length(fd.car_length)
  end
  if fd.has_initial_walk?
    xml.initial_walk do
      xml.travel_duration(fd.initial_walk_duration)
      xml.length(fd.initial_walk_length)
    end
  end
  if fd.has_final_walk?
    xml.final_walk do
      xml.travel_duration(fd.final_walk_duration)
      xml.length(fd.final_walk_length)
    end
  end
end
