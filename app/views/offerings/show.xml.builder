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

xml.offering(:id => @offering.id, :href => offering_url(@offering)) do
  xml.offerer(:id => @offering.offerer.id,
    :href => user_url(@offering.offerer))
  xml.departure_place(:id => @offering.departure_place.id,
    :href => place_url(@offering.departure_place))
  xml.arrival_place(:id => @offering.arrival_place.id,
    :href => place_url(@offering.arrival_place))
  xml.departure_time(@offering.departure_time.xmlschema)
  xml.arrival_time(@offering.arrival_time.xmlschema)
  xml.expiry_time(@offering.expiry_time.xmlschema)
  xml.chilled_since(@offering.chilled_since.xmlschema)
  xml.created_at(@offering.created_at.xmlschema)
  xml.travel_duration(@offering.travel_duration)
  xml.length(@offering.length)
  xml.seating_capacity(@offering.seating_capacity)
end
