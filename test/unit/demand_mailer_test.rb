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

class DemandMailerTest < ActionMailer::TestCase


  def setup
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    @languages = []
    Language.find(:all).each { |lang| @languages << lang.name }
    #
    @processor = DemandProcessorMock.new
    DemandProcessorFactory.set_factory(
      DemandProcessorMockFactory.new(@processor))
  end


  def tear_down
    MailBodyParserFactory.clear_factory
    DemandProcessorFactory.clear_factory
  end


  test "receive demand from unknown user" do
    untrusted_email = TMail::Mail.new
    untrusted_email.from = "there_isn't_this_email_in_users_table"
    DemandMailer.receive(untrusted_email.to_s)
    #
    assert_equal 1, @emails.size
    assert_equal untrusted_email.from[0], @emails[0].to[0]
  end


  test "demand created reply" do
    demand = demands(:mickey_mouse_demand_n_1)
    @languages.each do |lang|
      email = DemandMailer.
        create_demand_created_reply(demand, demand.suitor, lang)
      assert_equal demand.suitor.email, email.to[0]
    end
  end


  test "unprocessable demand reply" do
    demand = Demand.new
    user = users(:donald_duck)
    assert ! demand.save # false
    @languages.each do |lang|
      email = DemandMailer.create_unprocessable_demand_reply(
        user, lang, demand.errors.to_a)
      assert_equal user.email, email.to[0]
    end
  end


  test "receive a valid demand" do
    demand = demands(:mickey_mouse_demand_n_1)
    # this demand must be valid!
    assert demand.valid?
    # setting factory
    demand.earliest_departure_time = 1.month.from_now
    demand.latest_arrival_time = (1.month + 1.day).from_now
    MailBodyParserFactory.set_factory(
      MailBodyParserFactoryMock.new(demand))
    #
    fake_mail = TMail::Mail.new
    fake_mail.from = demand.suitor.email
    # process the e-mail
    assert_difference('Demand.count', 1) do
      DemandMailer.receive(fake_mail.to_s)
      # the demand was valid
    end
    assert @processor.process_incoming_demand_called?
    # this should be the "demand created reply"
    assert_equal 1, @emails.size
    assert_equal demand.suitor.email,
        @emails[0].to[0]
  end


  test "receive an invalid demand" do
    # this demand must be invalid
    demand = Demand.new
    suitor = users(:donald_duck)
    # setting factory
    MailBodyParserFactory.set_factory(
      MailBodyParserFactoryMock.new(demand))
    #
    fake_mail = TMail::Mail.new
    fake_mail.from = suitor.email
    # process the e-mail
    assert_difference('Demand.count', 0) do
      DemandMailer.receive(fake_mail.to_s)
      # the demand was not valid
    end
    assert ! @processor.process_incoming_demand_called?
    # this should be the "unprocessable demand reply"
    assert_equal 1, @emails.size
    assert_equal suitor.email, @emails[0].to[0]
  end


  private


  class MailBodyParserFactoryMock

    def initialize(demand)
      @demand = demand
    end


    def build_parser(mail_body, lang)
      MockParser.new(@demand)
    end

  end # class MailBodyParserFactoryMock


  class MockParser

    def initialize(demand)
      @demand = demand
    end


    def get_departure_place
      @demand.departure_place
    end


    def get_arrival_place
      @demand.arrival_place
    end


    def get_earliest_departure_time
      @demand.earliest_departure_time
    end


    def get_expiry_time
      @demand.expiry_time
    end


    def get_latest_arrival_time
      @demand.latest_arrival_time
    end

  end # class MockParser


  ##############

  class DemandProcessorMockFactory

    def initialize(processor)
      @processor = processor
    end


    def build_processor
      @processor
    end

  end # class DemandProcessorMockFactory


  class DemandProcessorMock

    def initialize
      @process_incoming_demand_called = false
    end


    def process_incoming_demand_called?
      @process_incoming_demand_called
    end


    def clear_calls
      @process_incoming_demand_called = false
    end


    def process_incoming_demand(demand)
      @process_incoming_demand_called = true
    end


  end # class DemandProcessorMock

end
