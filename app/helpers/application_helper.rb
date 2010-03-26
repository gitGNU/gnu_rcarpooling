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


# Methods added to this helper will be available to all templates
# in the application.
module ApplicationHelper


  def title
    @page_title ||= "rcarpooling unconfigured"
  end


  def english_date(time)
    time.localtime.to_date.to_s
  end


  def italian_date(time)
    "#{time.localtime.day}/#{time.localtime.month}/" +
        "#{time.localtime.year}"
  end


  def hour_minute(time)
    "#{time.localtime.hour}:#{time.localtime.min}"
  end


  def english_date_time(time)
    english_date(time) + " " + hour_minute(time)
  end


  def italian_date_time(time)
    italian_date(time) + " " + hour_minute(time)
  end


  def application_name
    ApplicationData.application_name
  end

end
