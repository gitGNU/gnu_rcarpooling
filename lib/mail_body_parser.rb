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

class MailBodyParser

  @@TOKEN_DEP_PLACE_NAME_EN = "departure place name:"
  @@TOKEN_DEP_PLACE_NAME_IT = "nome posto di partenza:"

  @@TOKEN_DEP_ADDR_EN = "departure address:"
  @@TOKEN_DEP_ADDR_IT = "indirizzo di partenza:"

  @@TOKEN_ARR_PLACE_NAME_EN = "arrival place name:"
  @@TOKEN_ARR_PLACE_NAME_IT = "nome posto di arrivo:"

  @@TOKEN_ARR_ADDR_EN = "arrival address:"
  @@TOKEN_ARR_ADDR_IT = "indirizzo di arrivo:"

  @@TOKEN_SEATING_CAP_EN = "seating:"
  @@TOKEN_SEATING_CAP_IT = "posti disponibili:"

  @@TOKEN_DEP_TIME_EN = "departure time:"
  @@TOKEN_DEP_TIME_IT = "ora partenza:"

  @@TOKEN_EXP_TIME_EN = "expiry time:"
  @@TOKEN_EXP_TIME_IT = "ora scadenza:"


  @@TOKEN_E_DEP_TIME_EN = "earliest departure time:"
  @@TOKEN_E_DEP_TIME_IT = "ora minima partenza:"

  @@TOKEN_L_ARR_TIME_EN = "latest arrival time:"
  @@TOKEN_L_ARR_TIME_IT = "ora massima arrivo:"



  def initialize(mail_body, lang)
    if "en" != lang and "it" != lang
      raise Exception.new("unsupported language")
    end
    @mail_body = mail_body
    @lang = lang
  end


  # both demands and offerings
  def get_departure_place
    if "en" == @lang
      if @mail_body =~ /#{@@TOKEN_DEP_PLACE_NAME_EN}/
        dep_place_name =
            @mail_body[/#{@@TOKEN_DEP_PLACE_NAME_EN}[\s]+([^\n]+)\n/,
                       1]
        Place.find_by_name(dep_place_name)
      elsif @mail_body =~ /#{@@TOKEN_DEP_ADDR_EN}/
        t = @@TOKEN_DEP_ADDR_EN
        m = /#{t}[\s]*([\w\s]+),[\s]*([\w\s]+),[\s]*([\w\s]+)\n/.
          match(@mail_body)
        civic_n = m[1].to_i
        street = m[2].strip
        city = m[3].strip
        Place.find(:first, :conditions => ["city = ? and " +
                                           "civic_number = ? and " +
                                           "street = ?",
                                           city, civic_n, street])
      end
      # END OF LANGUAGE "en"
    elsif "it" == @lang
      if @mail_body =~ /#{@@TOKEN_DEP_PLACE_NAME_IT}/
        dep_place_name =
            @mail_body[/#{@@TOKEN_DEP_PLACE_NAME_IT}[\s]+([^\n]+)\n/,
                       1]
        Place.find_by_name(dep_place_name)
      elsif @mail_body =~ /#{@@TOKEN_DEP_ADDR_IT}/
        t = @@TOKEN_DEP_ADDR_IT
        m = /#{t}[\s]*([\w\s]+),[\s]*([\w\s]+),[\s]*([\w\s]+)\n/.
          match(@mail_body)
        civic_n = m[2].to_i
        street = m[1].strip
        city = m[3].strip
        Place.find(:first, :conditions => ["city = ? and " +
                                           "civic_number = ? and " +
                                           "street = ?",
                                           city, civic_n, street])
      end
    end
    # END OF LANGUAGE "it"
  end # method get_departure_place


  # both  demands and offerings
  def get_arrival_place
    if "en" == @lang
      if @mail_body =~ /#{@@TOKEN_ARR_PLACE_NAME_EN}/
        place_name =
            @mail_body[/#{@@TOKEN_ARR_PLACE_NAME_EN}[\s]+([^\n]+)\n/,
                       1]
        Place.find_by_name(place_name)
      elsif @mail_body =~ /#{@@TOKEN_ARR_ADDR_EN}/
        t = @@TOKEN_ARR_ADDR_EN
        m = /#{t}[\s]*([\w\s]+),[\s]*([\w\s]+),[\s]*([\w\s]+)\n/.
          match(@mail_body)
        civic_n = m[1].to_i
        street = m[2].strip
        city = m[3].strip
        Place.find(:first, :conditions => ["city = ? and " +
                                           "civic_number = ? and " +
                                           "street = ?",
                                           city, civic_n, street])
      end
      # END OF LANGUAGE "en"
    elsif "it" == @lang
      if @mail_body =~ /#{@@TOKEN_ARR_PLACE_NAME_IT}/
        place_name =
            @mail_body[/#{@@TOKEN_ARR_PLACE_NAME_IT}[\s]+([^\n]+)\n/,
                       1]
        Place.find_by_name(place_name)
      elsif @mail_body =~ /#{@@TOKEN_ARR_ADDR_IT}/
        t = @@TOKEN_ARR_ADDR_IT
        m = /#{t}[\s]*([\w\s]+),[\s]*([\w\s]+),[\s]*([\w\s]+)\n/.
          match(@mail_body)
        civic_n = m[2].to_i
        street = m[1].strip
        city = m[3].strip
        Place.find(:first, :conditions => ["city = ? and " +
                                           "civic_number = ? and " +
                                           "street = ?",
                                           city, civic_n, street])
      end
    end
    # END OF LANGUAGE "it"
  end # method get_arrival_place


  # only for offerings
  def get_seating_capacity
    if "en" == @lang
      token = @@TOKEN_SEATING_CAP_EN
      # END OF LANGUAGE "en"
    elsif "it" == @lang
      token = @@TOKEN_SEATING_CAP_IT
    end
    # END OF LANGUAGE "it"
    # end of all languages
    if @mail_body =~ /#{token}.*\s(\d+).*\n/
      $1.to_i
    end
  end


  # only for offerings
  def get_departure_time
    token = ""
    if "en" == @lang
      token = @@TOKEN_DEP_TIME_EN
    elsif "it" == @lang
      token = @@TOKEN_DEP_TIME_IT
    end
    get_date_time(token, @mail_body)
  end


  # both demands and offerings
  def get_expiry_time
    token = ""
    if "en" == @lang
      token = @@TOKEN_EXP_TIME_EN
    elsif "it" == @lang
      token = @@TOKEN_EXP_TIME_IT
    end
    get_date_time(token, @mail_body)
  end


  # only for demands
  def get_earliest_departure_time
    token = ""
    if "en" == @lang
      token = @@TOKEN_E_DEP_TIME_EN
    elsif "it" == @lang
      token = @@TOKEN_E_DEP_TIME_IT
    end
    get_date_time(token, @mail_body)
  end


  # only for demands
  def get_latest_arrival_time
    token = ""
    if "en" == @lang
      token = @@TOKEN_L_ARR_TIME_EN
    elsif "it" == @lang
      token = @@TOKEN_L_ARR_TIME_IT
    end
    get_date_time(token, @mail_body)
  end


  private


  def get_date_time(token_id, string)
    if string =~ /#{token_id}/
      match_time = /#{token_id}.*\s(\d{1,2}):(\d{1,2})/.match(string)
      match_date = /#{token_id}.*\s(\d{1,2})\/(\d{1,2})\/(\d{4})/.match(
        string)
      Time.local(match_date[3], match_date[2], match_date[1],
                 match_time[1], match_time[2])
    end
  end


end
