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

class OfferingMailerTest < ActionMailer::TestCase


  def setup
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    @languages = []
    Language.find(:all).each { |lang| @languages << lang.name }
    #
    @processor = OfferingProcessorMock.new
    OfferingProcessorFactory.set_factory(
      OfferingProcessorMockFactory.new(@processor))
  end


  def tear_down
    MailBodyParserFactory.clear_factory
    OfferingProcessorFactory.clear_factory
  end


  test "receive offering from unknown user" do
    untrusted_email = TMail::Mail.new
    untrusted_email.from = "there_isn't_this_email_in_users_table"
    OfferingMailer.receive(untrusted_email.to_s)
    #
    assert_equal 1, @emails.size
    assert_equal untrusted_email.from[0], @emails[0].to[0]
  end


  test "offering created reply" do
    offering = offerings(:donald_duck_offering_n_1)
    @languages.each do |lang|
      email = OfferingMailer.
        create_offering_created_reply(offering, offering.offerer, lang)
      assert_equal offering.offerer.email, email.to[0]
    end
  end


  test "unprocessable offering reply" do
    offering = Offering.new
    user = users(:donald_duck)
    assert ! offering.save # false
    @languages.each do |lang|
      email = OfferingMailer.create_unprocessable_offering_reply(
        user, lang, offering.errors.to_a)
      assert_equal user.email, email.to[0]
    end
  end


  test "receive a valid offering" do
    offering = offerings(:donald_duck_offering_n_1)
    # this offering must be valid!
    offering.departure_time = 8.hours.from_now
    offering.arrival_time = 10.hours.from_now
    offering.expiry_time = 7.hours.from_now
    assert offering.valid?
    # setting factory
    MailBodyParserFactory.set_factory(
      MailBodyParserFactoryMock.new(offering))
    #
    fake_mail = TMail::Mail.new
    fake_mail.from = offering.offerer.email
    # process the e-mail
    assert_difference('Offering.count', 1) do
      OfferingMailer.receive(fake_mail.to_s)
      # the offering was valid
    end
    assert @processor.process_incoming_offering_called?
    # this should be the "offering created reply"
    assert_equal 1, @emails.size
    assert_equal offering.offerer.email,
        @emails[0].to[0]
  end


  test "receive an invalid offering" do
    # this offering must be invalid
    offering = Offering.new
    offerer = users(:donald_duck)
    # setting factory
    MailBodyParserFactory.set_factory(
      MailBodyParserFactoryMock.new(offering))
    #
    fake_mail = TMail::Mail.new
    fake_mail.from = offerer.email
    # process the e-mail
    assert_difference('Offering.count', 0) do
      OfferingMailer.receive(fake_mail.to_s)
      # the offering was not valid
    end
    assert ! @processor.process_incoming_offering_called?
    # this should be the "unprocessable offering reply"
    assert_equal 1, @emails.size
    assert_equal offerer.email, @emails[0].to[0]
  end


  private


  class MailBodyParserFactoryMock

    def initialize(offering)
      @offering = offering
    end


    def build_parser(mail_body, lang)
      MockParser.new(@offering)
    end

  end # class MailBodyParserFactoryMock


  class MockParser

    def initialize(offering)
      @offering = offering
    end


    def get_departure_place
      @offering.departure_place
    end


    def get_arrival_place
      @offering.arrival_place
    end


    def get_departure_time
      @offering.departure_time
    end


    def get_expiry_time
      @offering.expiry_time
    end


    def get_seating_capacity
      @offering.seating_capacity
    end

  end # class MockParser


  ##############

  class OfferingProcessorMockFactory

    def initialize(processor)
      @processor = processor
    end


    def build_processor
      @processor
    end

  end # class OfferingProcessorMockFactory


  class OfferingProcessorMock

    def initialize
      @process_incoming_offering_called = false
    end


    def process_incoming_offering_called?
      @process_incoming_offering_called
    end


    def clear_calls
      @process_incoming_offering_called = false
    end


    def process_incoming_offering(offering)
      @process_incoming_offering_called = true
    end


  end # class OfferingProcessorMock


end
