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

class MessageTest < ActiveSupport::TestCase

  test "valid message" do
    fm = forwarded_messages(:one_without_message)
    m = Message.new(:sender => users(:donald_duck),
                    :subject => "hello",
                    :content => "this is a text, bla bla")
    fm.message = m
    m.forwarded_messages << fm
    assert m.valid?
    assert m.save
  end


  test "invalid with empty required fields" do
    m = Message.new
    assert !m.valid?
    assert m.errors.invalid?(:sender)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        m.errors.on(:sender)
    assert m.errors.invalid?(:subject)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        m.errors.on(:subject)
    assert m.errors.invalid?(:content)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        m.errors.on(:content)
    assert m.errors.invalid?(:forwarded_messages)
    assert_equal I18n.t('activerecord.errors.messages.message.' +
                        'forwarded_messages_empty'),
                        m.errors.on(:forwarded_messages)
  end


  test "subject cannot be over 100" do
    subject = ""
    11.times { subject += "qqqqqqqqqq" }
    m = Message.new :subject => subject
    assert !m.valid?
    assert m.errors.invalid?(:subject)
    assert_equal I18n.t('activerecord.errors.messages.too_long',
                        :count => 100), m.errors.on(:subject)
  end


  test "content cannot be over 20K chars" do
    content = ""
    1001.times { content += "aaaaaaaaaaaaaaaaaaaa" }
    #
    m = Message.new :content => content
    assert !m.valid?
    assert m.errors.invalid?(:content)
    assert_equal I18n.t('activerecord.errors.messages.too_long',
                        :count => 20000),
                        m.errors.on(:content)
  end


  test "invalid if forwarded messages is invalid" do
    fm = ForwardedMessage.new #invalid
    m = Message.new
    m.forwarded_messages << fm
    assert !m.valid?
    assert m.errors.invalid?(:forwarded_messages)
    assert_equal I18n.t('activerecord.errors.messages.message.' +
                        'forwarded_messages_invalid'),
                        m.errors.on(:forwarded_messages)
  end


  test "recipients association" do
    message = messages(:two)
    assert_equal 2, message.recipients.length
    assert message.recipients.include?(users(:donald_duck))
    assert message.recipients.include?(users(:user_N))
  end

end
