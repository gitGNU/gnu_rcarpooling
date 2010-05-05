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

xml.user(:id => @user.id, :href => user_url(@user)) do
  xml.first_name(h @user.first_name)
  xml.last_name(h @user.last_name)
  xml.sex(h @user.sex)
  xml.nick_name(h @user.nick_name)
  xml.created_at(@user.created_at.xmlschema)
  xml.email(h @user.email) if @user.shows_email?
  if @user.shows_telephone_number?
    xml.telephone_number(h @user.telephone_number)
  end
  if @user.shows_vehicle_registration_plate?
    xml.vehicle_registration_plate(h @user.vehicle_registration_plate)
  end
end
