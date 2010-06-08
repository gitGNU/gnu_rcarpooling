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

class AdTest < ActiveSupport::TestCase

  def setup
    @emails = ActionMailer::Base.deliveries
    @emails.clear
  end


  test "create an ad" do
    ad = Ad.new :subject => "hello world!", :content => "foo bar"
    assert ad.valid?
    assert ad.save
  end


  test "invalid without required fields" do
    ad = Ad.new
    assert !ad.valid?
    assert ad.errors.invalid?(:subject)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        ad.errors.on(:subject)
    assert ad.errors.invalid?(:content)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        ad.errors.on(:content)
  end


  test "forward by email" do
    ad = ads(:one)
    ad.forward_by_email
    assert_equal 1, @emails.size
  end

end
