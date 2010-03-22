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
  xml.qualification(@user.qualification)
  xml.first_name(@user.first_name)
  xml.last_name(@user.last_name)
  xml.sex(@user.sex)
  xml.lang(@user.lang)
  xml.nick_name(@user.nick_name)
  xml.email(@user.email)
  xml.score(@user.score)
  xml.max_foot_length(@user.max_foot_length)
  xml.created_at(@user.created_at)
  xml.updated_at(@user.updated_at)
end
