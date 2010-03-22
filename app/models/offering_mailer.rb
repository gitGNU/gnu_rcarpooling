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

class OfferingMailer < ActionMailer::Base

  helper :application


  def receive(email)
    # is the sender a user of this system?
    user = User.find_by_email(email.from[0])
    if user # the sender is ok :)
      # now parse the e-mail body
      parser = MailBodyParserFactory.build_parser(email.body, user.lang)
      # retrieve required fields
      departure_place = parser.get_departure_place
      arrival_place = parser.get_arrival_place
      departure_time = parser.get_departure_time
      expiry_time = parser.get_expiry_time
      seating_capacity = parser.get_seating_capacity
      arrival_time = nil
      length = nil
      # create the new offering
      offering = Offering.new(:departure_place => departure_place,
                              :arrival_place => arrival_place,
                              :departure_time => departure_time,
                              :expiry_time => expiry_time,
                              :seating_capacity => seating_capacity,
                              :offerer => user)
      # fill other fields
      if offering.departure_place and offering.arrival_place
        edge = EdgeByCar.
          find_by_departure_place_id_and_arrival_place_id(
            departure_place.id, arrival_place.id)
        if edge
          if offering.departure_time
            offering.arrival_time = offering.departure_time +
                edge.travel_duration.minutes
          end
          offering.length = edge.length
        end
      end
      #
      if offering.save
        # the offering is OK, process it :)
        processor = OfferingProcessorFactory.build_processor
        processor.process_incoming_offering(offering)
        # reply to the offerer
        OfferingMailer.deliver_offering_created_reply(offering, user,
                                                      user.lang)
      else
        # there are some bad params :(
        OfferingMailer.deliver_unprocessable_offering_reply(user,
                                                            user.lang,
                                                  offering.errors.to_a)
      end
    else # the sender is not a system's user :P
      OfferingMailer.deliver_not_authenticated_reply(email.from[0])
    end
  end


  def not_authenticated_reply(email_address)
    subject     ApplicationData.application_name + " - " +
        "your are not a trusted user"
    recipients  email_address
    from        ApplicationData.reply_source_address
    body        render_message("offering_mailer/en/" +
                               "not_authenticated_reply", {})
  end


  def offering_created_reply(offering, user, lang)
    subject_content = nil
    subject_content = "offering created" if "en" == lang
    subject_content = "offerta accettata" if "it" == lang
    #
    subject     ApplicationData.application_name + " - " +
        subject_content
    recipients  user.nice_email_address
    from        ApplicationData.reply_source_address
    body        render_message("offering_mailer/#{lang}/" +
                               "offering_created_reply",
                               :offering => offering,
                               :user => user,
                               :lang => lang)
  end


  def unprocessable_offering_reply(user, lang, offering_errors_array)
    subject_content = nil
    subject_content = "offering unprocessable" if "en" == lang
    subject_content = "offerta non processabile" if "it" == lang
    #
    subject     ApplicationData.application_name + " - " +
        subject_content
    recipients  user.nice_email_address
    from        ApplicationData.reply_source_address
    body        render_message("offering_mailer/#{lang}/" +
                               "unprocessable_offering_reply",
                               :offering_errors =>
                                    offering_errors_array,
                               :user => user,
                               :lang => lang)
  end

end
