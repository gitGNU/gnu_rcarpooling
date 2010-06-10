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

require 'test_helper'

class MailBodyParserTest < ActiveSupport::TestCase

  def setup
    @place_finder = Place
  end


  test "parser process only english or italian" do
    assert_raise(Exception) { MailBodyParser.new("", 'fr', nil) }
  end


  test "should get departure place by name, language en, 1" do
    email_body = "\ndeparture: " +
        "#{places(:sede_di_via_ravasi).name}    \n \n   \n"
    parser = MailBodyParser.new(email_body, 'en', @place_finder)
    assert_equal places(:sede_di_via_ravasi),
        parser.get_departure_place
  end


  test "should get departure place by name, language it, 1" do
    email_body = "\n partenza:     " +
        "#{places(:sede_di_via_ravasi).name}    \n \n   \n"
    #
    parser = MailBodyParser.new(email_body, 'it', @place_finder)
    assert_equal places(:sede_di_via_ravasi),
        parser.get_departure_place
  end


  test "should get departure place by name, language en, 2" do
    email_body = "\ndeparture: " +
        "#{places(:point_and_apostrophe).name}    \n \n   \n"
    parser = MailBodyParser.new(email_body, 'en', @place_finder)
    assert_equal places(:point_and_apostrophe),
        parser.get_departure_place
  end


  test "should get departure place by name, language it, 2" do
    email_body = "\n partenza:     " +
        "#{places(:point_and_apostrophe).name}    \n \n   \n"
    #
    parser = MailBodyParser.new(email_body, 'it', @place_finder)
    assert_equal places(:point_and_apostrophe),
        parser.get_departure_place
  end


  test "should get departure place by address, language en, 1" do
    place = places(:sede_di_via_ravasi)
    email_body = "\ndeparture address: " +
        "#{place.civic_number}, #{place.street}, #{place.city}  \n \n"
    parser = MailBodyParser.new(email_body, 'en', @place_finder)
    assert_equal place, parser.get_departure_place
  end


  test "should get departure place by address, language it, 1" do
    place = places(:sede_di_via_ravasi)
    email_body = "\nindirizzo di partenza: " +
        "#{place.street},#{place.civic_number}, #{place.city}  \n \n"
    parser = MailBodyParser.new(email_body, 'it', @place_finder)
    assert_equal place, parser.get_departure_place
  end


  test "should get departure place by address, language en, 2" do
    place = places(:point_and_apostrophe)
    email_body = "\ndeparture address: " +
        "#{place.civic_number}, #{place.street}, #{place.city}  \n \n"
    parser = MailBodyParser.new(email_body, 'en', @place_finder)
    assert_equal place, parser.get_departure_place
  end


  test "should get departure place by address, language it, 2" do
    place = places(:point_and_apostrophe)
    email_body = "\nindirizzo di partenza: " +
        "#{place.street},#{place.civic_number}, #{place.city}  \n \n"
    parser = MailBodyParser.new(email_body, 'it', @place_finder)
    assert_equal place, parser.get_departure_place
  end


  test "should get arrival place by name, language en" do
    email_body = "\narrival: " +
        "#{places(:sede_di_via_ravasi).name}    \n \n   \n"
    parser = MailBodyParser.new(email_body, 'en', @place_finder)
    assert_equal places(:sede_di_via_ravasi),
        parser.get_arrival_place
  end


  test "should get arrival place by name, language it" do
    email_body = "\n arrivo:     " +
        "#{places(:sede_di_via_ravasi).name}    \n \n   \n"
    #
    parser = MailBodyParser.new(email_body, 'it', @place_finder)
    assert_equal places(:sede_di_via_ravasi),
        parser.get_arrival_place
  end


  test "should get arrival place by address, language en" do
    place = places(:sede_di_via_ravasi)
    email_body = "\n arrival address: " +
        "#{place.civic_number}, #{place.street}, #{place.city}  \n \n"
    parser = MailBodyParser.new(email_body, 'en', @place_finder)
    assert_equal place, parser.get_arrival_place
  end


  test "should get arrival place by address, language it" do
    place = places(:sede_di_via_ravasi)
    email_body = "\nindirizzo di arrivo: " +
        "#{place.street},#{place.civic_number}, #{place.city}  \n \n"
    parser = MailBodyParser.new(email_body, 'it', @place_finder)
    assert_equal place, parser.get_arrival_place
  end


  test "should get seating capacity, language en" do
    email_body = "\n \n kasdjfsh\n seating: 12\n"
    #
    parser = MailBodyParser.new(email_body, 'en', nil)
    assert_equal 12, parser.get_seating_capacity
  end


  test "should get seating capacity, language it" do
    email_body = "\n \n kasdjfsh\n posti: 12  dfjgh3456g\n"
    #
    parser = MailBodyParser.new(email_body, 'it', nil)
    assert_equal 12, parser.get_seating_capacity
  end


  test "should get departure time, language en" do
    email_body = "\n departure time: 14:20  2010/3/12 \n"
    #
    parser = MailBodyParser.new(email_body, 'en', nil)
    time = parser.get_departure_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


  test "should get departure time, language it" do
    email_body = "\n ora partenza: 14:20  12/3/2010"
    #
    parser = MailBodyParser.new(email_body, 'it', nil)
    time = parser.get_departure_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


  test "should get expiry time, language en" do
    email_body = "\n expiry time: 14:20  2010/3/12 \n"
    #
    parser = MailBodyParser.new(email_body, 'en', nil)
    time = parser.get_expiry_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


  test "should get expiry time, language it" do
    email_body = "\n ora scadenza: 14:20  12/3/2010"
    #
    parser = MailBodyParser.new(email_body, 'it', nil)
    time = parser.get_expiry_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


  test "should get earliest departure time, language en" do
    email_body = "\n earliest departure time: 14:20  2010/3/12 \n"
    #
    parser = MailBodyParser.new(email_body, 'en', nil)
    time = parser.get_earliest_departure_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


  test "should get earliest departure time, language it" do
    email_body = "\n ora minima partenza: 14:20  12/3/2010"
    #
    parser = MailBodyParser.new(email_body, 'it', nil)
    time = parser.get_earliest_departure_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


  test "should get latest arrival time, language en" do
    email_body = "\n latest arrival time: 14:20  2010/03/12 \n"
    #
    parser = MailBodyParser.new(email_body, 'en', nil)
    time = parser.get_latest_arrival_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


  test "should get latest arrival time, language it" do
    email_body = "\n ora massima arrivo: 14:20  12/03/2010"
    #
    parser = MailBodyParser.new(email_body, 'it', nil)
    time = parser.get_latest_arrival_time
    assert_not_nil time
    assert_equal 14, time.hour
    assert_equal 20, time.min
    assert_equal 12, time.day
    assert_equal 3, time.month
    assert_equal 2010, time.year
    assert_equal 0, time.sec
  end


end
