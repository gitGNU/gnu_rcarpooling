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

class NotificationMailer < ActionMailer::Base


  helper :application


  def notify_fulfilled_demand(fulfilled_demand, user, lang, subject,
                              from)
    subject    subject
    recipients user.nice_email_address
    from       from
    body       render_message("notification_mailer/" + lang +
                              "/notify_fulfilled_demand",
                              :fulfilled_demand => fulfilled_demand,
                              :user => user,
                              :lang => lang)
  end


  def notify_demand_no_longer_fulfilled(fulfilled_demand, user, lang,
                                        subject, from)
    subject    subject
    recipients user.nice_email_address
    from       from
    body       render_message("notification_mailer/" + lang +
                              "/notify_demand_no_longer_fulfilled",
                              :fulfilled_demand => fulfilled_demand,
                              :user => user,
                              :lang => lang)
  end


  def no_solution_for_a_demand(demand, lang, subject, from)
    subject     subject
    recipients  demand.suitor.nice_email_address
    from        from
    body        render_message("notification_mailer/" + lang +
                               "/no_solution_for_a_demand",
                               :demand => demand,
                               :user => demand.suitor,
                               :lang => lang)
  end


  def passengers_list(offering, lang, subject, from)
    subject     subject
    recipients  offering.offerer.nice_email_address
    from        from
    body        render_message("notification_mailer/" + lang +
                               "/passengers_list",
                               :offering => offering,
                               :user => offering.offerer,
                               :lang => lang)
  end

end
