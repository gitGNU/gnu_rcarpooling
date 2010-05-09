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

class Place < ActiveRecord::Base


  validates_numericality_of :latitude, :longitude


  validates_presence_of :name


  def address(lang = "en")
    if "en" == lang
      if street and city
        if civic_number
          "#{civic_number}, #{street}, #{city}"
        else
          "#{street}, #{city}"
        end
      else
        "latitude = #{latitude}, longitude = #{longitude}"
      end
      # end of english
    elsif "it" == lang
      if street and city
        if civic_number
          "#{street} #{civic_number}, #{city}"
        else
          "#{street}, #{city}"
        end
      else
        "latitudine = #{latitude}, longitudine = #{longitude}"
      end
      # end of italian
    end # languages
  end # method address


  def self.average_latitude
    average_latitude = 0.0
    places = self.find :all
    places.each { |p| average_latitude += p.latitude }
    average_latitude /= places.size
  end


  def self.average_longitude
    average_longitude = 0.0
    places = self.find :all
    places.each { |p| average_longitude += p.longitude }
    average_longitude /= places.size
  end


end
