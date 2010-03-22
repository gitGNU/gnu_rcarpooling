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

class Notifier


  # notifies user that his/her demand has been fulfilled :)
  def notify_fulfilled_demand(fulfilled_demand)
    user = fulfilled_demand.suitor
    subject = ApplicationData.application_name + " - " +
        "your demand has been fulfilled :)"
    if "it" == user.lang
      subject = ApplicationData.application_name + " - " +
          "la Sua richesta è stata soddisfatta :)"
    end
    NotificationMailer.deliver_notify_fulfilled_demand(
      fulfilled_demand, user,
      user.lang,
      subject, ApplicationData.notifications_source_address)
  end


  # revokes a travel solution previously notified :(
  # it is caused by a driver's revoking
  def notify_demand_no_longer_fulfilled(fulfilled_demand)
    user = fulfilled_demand.suitor
    subject = ApplicationData.application_name + " - " +
        "previous solution will no longer " +
        "available :("
    if "it" == user.lang
      subject = ApplicationData.application_name + " - " +
          "la precedente soluzione non è più usufruibile :("
    end
    NotificationMailer.deliver_notify_demand_no_longer_fulfilled(
      fulfilled_demand, user,
      user.lang,
      subject, ApplicationData.notifications_source_address)
  end


  # default reply to a demand: no solution. Scheduled at
  # demand.expiry_time
  def schedule_default_reply_to_demand(demand)
    time_obj = demand.expiry_time.localtime
    year = time_obj.year.to_s
    month = time_obj.month.to_s
    month = "0" + month if month.length < 2
    day = time_obj.day.to_s
    day = "0" + day if day.length < 2
    hour = time_obj.hour.to_s
    hour = "0" + hour if hour.length < 2
    min = time_obj.min.to_s
    min = "0" + min if min.length < 2
    sec = time_obj.sec.to_s
    sec = "0" + sec if sec.length < 2
    time_of_execution = year + month + day + hour + min + "." +
        sec
    #
    pipe = IO.popen("/usr/bin/at -t #{time_of_execution} 2>&1", "w+")
    pipe.puts "#{ENV['_']} script/runner \
        -e #{ENV['RAILS_ENV']} \
        Notifier.send_default_reply_for_a_demand\\(#{demand.id}\\)"
    pipe.close_write
    output_lines = pipe.lines.to_a
    pipe.close_read
    output_lines[output_lines.size - 1].chomp =~ /^job\s(\d+)\s/
    $1.to_i
  end


  def schedule_passengers_list(offering)
    time_obj = offering.expiry_time.localtime
    year = time_obj.year.to_s
    month = time_obj.month.to_s
    month = "0" + month if month.length < 2
    day = time_obj.day.to_s
    day = "0" + day if day.length < 2
    hour = time_obj.hour.to_s
    hour = "0" + hour if hour.length < 2
    min = time_obj.min.to_s
    min = "0" + min if min.length < 2
    sec = time_obj.sec.to_s
    sec = "0" + sec if sec.length < 2
    time_of_execution = year + month + day + hour + min + "." +
        sec
    #
    pipe = IO.popen("/usr/bin/at -t #{time_of_execution} 2>&1", "w+")
    pipe.puts "#{ENV['_']} script/runner \
        -e #{ENV['RAILS_ENV']} \
        Notifier.send_passengers_list\\(#{offering.id}\\)"
    pipe.close_write
    output_lines = pipe.lines.to_a
    pipe.close_read
    output_lines[output_lines.size - 1].chomp =~ /^job\s(\d+)\s/
    $1.to_i
  end


  # method called with ruby script/runner from an "at" job
  def self.send_default_reply_for_a_demand(demand_id)
    demand = Demand.find(demand_id)
    subject = ApplicationData.application_name + " - " +
        "no solution found :("
    if "it" == demand.suitor.lang
      subject = ApplicationData.application_name + " - " +
          "nessuna soluzione trovata :("
    end
    NotificationMailer.deliver_no_solution_for_a_demand(
      demand, demand.suitor.lang, subject,
      ApplicationData.notifications_source_address)
  end


  # method called with ruby script/runner from an "at" job
  def self.send_passengers_list(offering_id)
    offering = Offering.find(offering_id)
    subject = ApplicationData.application_name + " - " +
        "passengers list"
    if "it" == offering.offerer.lang
      subject = ApplicationData.application_name + " - " +
          "lista dei passeggeri"
    end
    NotificationMailer.deliver_passengers_list(
      offering, offering.offerer.lang, subject,
      ApplicationData.notifications_source_address)
  end


  def remove_scheduled_notification(job_number)
    `atrm #{job_number}`
  end


end
