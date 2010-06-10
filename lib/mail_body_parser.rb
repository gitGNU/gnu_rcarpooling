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

  TOKEN_DEP_PLACE_NAME = { 'en' => 'departure:',
                           'it' => 'partenza:' }
  TOKEN_DEP_ADDR = { 'en' => 'departure address:',
                     'it' => 'indirizzo di partenza:' }

  TOKEN_ARR_PLACE_NAME = { 'en' => 'arrival:',
                           'it' => 'arrivo:' }
  TOKEN_ARR_ADDR = { 'en' => 'arrival address:',
                     'it' => 'indirizzo di arrivo:' }

  TOKEN_SEATING_CAP = { 'en' => 'seating:',
                        'it' => 'posti:' }

  TOKEN_DEP_TIME = { 'en' => 'departure time:',
                     'it' => 'ora partenza:' }

  TOKEN_EXP_TIME = { 'en' => 'expiry time:',
                     'it' => 'ora scadenza:' }

  TOKEN_E_DEP_TIME = { 'en' => 'earliest departure time:',
                       'it' => 'ora minima partenza:' }

  TOKEN_L_ARR_TIME = { 'en' => 'latest arrival time:',
                       'it' => 'ora massima arrivo:' }


  attr_reader :mail_body, :lang, :place_finder

  def initialize(mail_body, lang, place_finder)
    if "en" != lang and "it" != lang
      raise Exception.new("unsupported language")
    end
    @mail_body, @lang, @place_finder = mail_body, lang, place_finder
  end


  # both demands and offerings
  def get_departure_place
    get_place(TOKEN_DEP_PLACE_NAME[@lang], TOKEN_DEP_ADDR[@lang],
              @lang, @mail_body, @place_finder)
  end


  # both demands and offerings
  def get_arrival_place
    get_place(TOKEN_ARR_PLACE_NAME[@lang], TOKEN_ARR_ADDR[@lang],
              @lang, @mail_body, @place_finder)
  end


  # only for offerings
  def get_seating_capacity
    pattern = /^.*#{TOKEN_SEATING_CAP[@lang]} *(\d{1,2}).*$/
    $1.to_i if pattern =~ @mail_body
  end


  # only for offerings
  def get_departure_time
    get_date_time(TOKEN_DEP_TIME[@lang], @lang, @mail_body)
  end


  # both demands and offerings
  def get_expiry_time
    get_date_time(TOKEN_EXP_TIME[@lang], @lang, @mail_body)
  end


  # only for demands
  def get_earliest_departure_time
    get_date_time(TOKEN_E_DEP_TIME[@lang], @lang, @mail_body)
  end


  # only for demands
  def get_latest_arrival_time
    get_date_time(TOKEN_L_ARR_TIME[@lang], @lang, @mail_body)
  end


  private


  def get_place(token_name, token_address, lang, string, place_finder)
    pattern = /^.*#{token_name} *([\w .']+)$/
    if pattern =~ string
      place_finder.find_by_name($1.strip)
    else
      # try find by address
      pattern = /^.*#{token_address} *([\w .']+),([\w .']+),([\w .']+)$/
      civic_n, street, city = nil
      if pattern =~ string
        if 'it' == lang
          street, civic_n, city = $1, $2, $3
        elsif 'en' == lang
          civic_n, street, city = $1, $2, $3
        end
        street.strip!
        civic_n.strip!
        city.strip!
        street && civic_n && city &&
            place_finder.find_by_city_and_street_and_civic_number(city,
                                                                  street,
                                                                  civic_n)
      end
    end
  end


  def get_date_time(token, lang, string)
    year, month, day, hour, minute = nil
    hour, minute = $1, $2 if string =~ /#{token}.* (\d{1,2}):(\d{1,2})/
    if string =~ %r{#{token}.* (\d{1,4})/(\d{1,2})/(\d{1,4})}
      if 'it' == lang
        year, month, day = $3, $2, $1
      elsif 'en' == lang
        year, month, day = $1, $2, $3
      end
    end
    begin
      year && month && day && hour && minute && Time.local(year, month,
                                                           day, hour,
                                                           minute)
    rescue Exception
      return nil
    end
  end

end
