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

class MessageMailerTest < ActionMailer::TestCase


  test "send a message" do
    message = messages(:two)
    recipient = message.recipients.first
    mail = MessageMailer.create_message(message, recipient)
    assert_equal recipient.email, mail.to[0]
    assert_equal ApplicationData.notifications_source_address, mail.from[0]
    assert_equal message.subject, mail.subject
  end


end
