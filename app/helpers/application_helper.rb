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


# Methods added to this helper will be available to all templates
# in the application.
module ApplicationHelper


  def title
    @page_title ||= ApplicationData.application_name
  end


  def hour_minute(time)
    "#{time.localtime.hour}:#{time.localtime.min}"
  end


  def application_name
    ApplicationData.application_name
  end


  def user_logged_in?
    session[:uid] && true
  end


  def user_logged
    User.find_by_id(session[:uid])
  end


  def user_logged_nick_name(max_length = 0)
    if user_logged_in?
      nick_name = user_logged.nick_name
      if max_length == 0
        nick_name
      else
        truncate(nick_name, max_length, "...")
      end
    else
      nil
    end
  end


  def snippet(string, max_length)
    truncate(string, :length => max_length, :omission => "...")
  end


  def required_field
    "<span style='color: red; font-weight: bold;'>*</span>"
  end


  def recipients_param(recipients)
    recipients.map { |r| "#{r.name}<#{r.id}>" }.join(',')
  end


  include WillPaginate::ViewHelpers

  def will_paginate_with_i18n(collection, options = {})
    will_paginate_without_i18n(collection,
                                options.merge(
                                    :previous_label => I18n.t(:previous),
                                    :next_label => I18n.t(:next)))
  end

  alias_method_chain :will_paginate, :i18n

end
