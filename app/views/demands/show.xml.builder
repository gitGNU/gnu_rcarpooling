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

xml.demand(:id => @demand.id, :href => demand_url(@demand)) do
  xml.suitor(:id => @demand.suitor.id, :href => user_url(@demand.suitor))
  xml.earliest_departure_time(@demand.earliest_departure_time.xmlschema)
  xml.latest_arrival_time(@demand.latest_arrival_time.xmlschema)
  xml.expiry_time(@demand.expiry_time.xmlschema)
  xml.created_at(@demand.created_at.xmlschema)
  xml.departure_place(:id => @demand.departure_place.id,
                      :href => place_url(@demand.departure_place))
  xml.arrival_place(:id => @demand.arrival_place.id,
                    :href => place_url(@demand.arrival_place))
end
