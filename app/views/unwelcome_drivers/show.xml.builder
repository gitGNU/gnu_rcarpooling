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

driver = @unwelcome_driver.driver

xml.unwelcome_driver(:id => @unwelcome_driver.id,
  :href => user_unwelcome_driver_url(:user_id =>
    @unwelcome_driver.user.id, :id => @unwelcome_driver.id)) do
  xml.user(:id => driver.id, :href => user_url(driver)) do
    xml.first_name(h driver.first_name)
    xml.last_name(h driver.last_name)
    xml.nick_name(h driver.nick_name)
  end
end
