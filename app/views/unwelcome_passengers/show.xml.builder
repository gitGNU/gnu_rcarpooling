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

passenger = @unwelcome_passenger.passenger

xml.unwelcome_passenger(:id => @unwelcome_passenger.id,
  :href => user_unwelcome_passenger_url(:user_id =>
    @unwelcome_passenger.user.id, :id => @unwelcome_passenger.id)) do
  xml.user(:id => passenger.id, :href => user_url(passenger)) do
    xml.first_name(h passenger.first_name)
    xml.last_name(h passenger.last_name)
    xml.nick_name(h passenger.nick_name)
  end
end
