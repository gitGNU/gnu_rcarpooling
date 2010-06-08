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

class AdMailerTest < ActionMailer::TestCase

  test "forward an ad" do
    ad = ads(:one)
    mail = AdMailer.create_ad(ad)
    assert_equal ApplicationData.notifications_source_address,
        mail.from[0]
    recipients = User.find(
      :all, :conditions => 'forward_ads_to_mail = true').map { |u| u.email }
    assert_equal recipients, mail.bcc
    assert_nil mail.to
    assert_equal "#{ApplicationData.application_name} - #{ad.subject}",
        mail.subject
    assert_equal ad.content, mail.body.delete("\n")
  end

end
