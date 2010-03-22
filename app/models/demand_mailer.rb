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

class DemandMailer < ActionMailer::Base

  helper :application


  def receive(email)
    user = User.find_by_email(email.from[0])
    if user
      # the user is authorized
      parser = MailBodyParserFactory.build_parser(email.body, user.lang)
      # extract fields
      departure_place = parser.get_departure_place
      arrival_place = parser.get_arrival_place
      earliest_departure_time = parser.get_earliest_departure_time
      latest_arrival_time = parser.get_latest_arrival_time
      expiry_time = parser.get_expiry_time
      # create the demand
      demand = Demand.new(:suitor => user,
                          :departure_place => departure_place,
                          :arrival_place => arrival_place,
                          :earliest_departure_time =>
                              earliest_departure_time,
                          :latest_arrival_time => latest_arrival_time,
                          :expiry_time => expiry_time)
      if demand.save
        processor = DemandProcessorFactory.build_processor
        processor.process_incoming_demand(demand)
        # reply to the suitor, all right :)
        DemandMailer.deliver_demand_created_reply(demand,
                                                  demand.suitor,
                                                  demand.suitor.lang)
      else
        # reply to the suitor, demand not valid :(
        DemandMailer.deliver_unprocessable_demand_reply(
          user, user.lang, demand.errors.to_a)
      end
    else
      # unknown user
      DemandMailer.deliver_not_authenticated_reply(email.from[0])
    end
  end # method receive


  def not_authenticated_reply(email_address)
    subject     ApplicationData.application_name + " - " +
        "your are not a trusted user"
    recipients  email_address
    from        ApplicationData.reply_source_address
    body        render_message("demand_mailer/en/" +
                               "not_authenticated_reply", {})
  end


  def demand_created_reply(demand, user, lang)
    subject_content = nil
    subject_content = "demand saved" if "en" == lang
    subject_content = "richiesta accettata" if "it" == lang
    #
    subject     ApplicationData.application_name + " - " +
        subject_content
    recipients  user.nice_email_address
    from        ApplicationData.reply_source_address
    body        render_message("demand_mailer/#{lang}/" +
                               "demand_created_reply",
                               :demand => demand,
                               :user => user,
                               :lang => lang)
  end


  def unprocessable_demand_reply(user, lang, demand_errors_array)
    subject_content = nil
    subject_content = "demand unprocessable" if "en" == lang
    subject_content = "richiesta non processabile" if "it" == lang
    #
    subject     ApplicationData.application_name + " - " +
        subject_content
    recipients  user.nice_email_address
    from        ApplicationData.reply_source_address
    body        render_message("demand_mailer/#{lang}/" +
                               "unprocessable_demand_reply",
                               :demand_errors =>
                                    demand_errors_array,
                               :user => user,
                               :lang => lang)
  end


end
