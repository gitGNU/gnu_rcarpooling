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
  xml.qualification(h @user.qualification)
  xml.first_name(h @user.first_name)
  xml.last_name(h @user.last_name)
  xml.sex(h @user.sex)
  xml.lang(h @user.lang)
  xml.nick_name(h @user.nick_name)
  xml.email(h @user.email)
  xml.score(h @user.score)
  xml.max_foot_length(h @user.max_foot_length)
  xml.created_at(h @user.created_at)
  xml.updated_at(h @user.updated_at)
  xml.black_list do
    @user.drivers_in_black_list.each do |driver|
      xml.user(:id => driver.id, :href => user_url(driver),
               :rel => "driver") do
        xml.first_name(h driver.first_name)
        xml.last_name(h driver.last_name)
        xml.nick_name(h driver.nick_name)
      end
    end
    @user.passengers_in_black_list.each do |passenger|
      xml.user(:id => passenger.id, :href => user_url(passenger),
               :rel => "passenger") do
        xml.first_name(h passenger.first_name)
        xml.last_name(h passenger.last_name)
        xml.nick_name(h passenger.nick_name)
      end
    end
  end
end
