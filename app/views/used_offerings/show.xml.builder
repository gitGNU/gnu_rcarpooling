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

uo = @used_offering
xml.used_offering(:id => uo.id, :href => used_offering_url(uo)) do
  xml.offerer(:id => uo.offerer.id, :href => user_url(uo.offerer))
  xml.offering(:id => uo.offering.id, :href => offering_url(uo.offering))
  xml.departure_place(:id => uo.departure_place.id,
                      :href => place_url(uo.departure_place))
  xml.arrival_place(:id => uo.arrival_place.id,
                    :href => place_url(uo.arrival_place))
  xml.departure_time(uo.departure_time.xmlschema)
  xml.arrival_time(uo.arrival_time.xmlschema)
  xml.expiry_time(uo.expiry_time.xmlschema)
  xml.chilled_since(uo.chilled_since.xmlschema)
  xml.passengers do
    uo.passengers.each do |p|
      xml.passenger(:id => p.id, :href => user_url(p))
    end
  end
end
