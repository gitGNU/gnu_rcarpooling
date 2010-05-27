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

class ForwardedMessageTest < ActiveSupport::TestCase

  test "valid forwarded message" do
    fm = ForwardedMessage.new(:recipient => users(:donald_duck),
                              :message => messages(:one))
    assert fm.valid?
    assert fm.save
  end


  test "default value for seen" do
    fm = ForwardedMessage.new
    assert !fm.seen
  end


  test "invalid with empty required fields" do
    fm = ForwardedMessage.new
    assert !fm.valid?
    assert fm.errors.invalid?(:recipient)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        fm.errors.on(:recipient)
    assert fm.errors.invalid?(:message)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        fm.errors.on(:message)
  end


  test "message sender cannot be the recipient" do
    fm = ForwardedMessage.new
    fm.message = messages(:mickey_mouse_sender)
    fm.recipient = users(:mickey_mouse)
    assert ! fm.valid?
    assert fm.errors.invalid?(:recipient)
    assert_equal I18n.t('activerecord.errors.messages.forwarded_message' +
                        '.recipient_must_be_distinct_from_sender'),
                        fm.errors.on(:recipient)
  end

end
