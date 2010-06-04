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

class MessagesControllerTest < ActionController::TestCase

  def setup
    @emails = ActionMailer::Base.deliveries
    @emails.clear
  end


  # POST /messages

  test "send message" do
    sender = users(:mickey_mouse)
    set_authorization_header(sender.nick_name, sender.password)
    #
    recipients = [users(:donald_duck), users(:user_N)]
    assert_difference('Message.count', 1) do
      assert_difference('ForwardedMessage.count', 2) do
        post :create, :message => { :subject => "hello world!",
                                    :content => "foo bar",
                                    :recipients_ids_string =>
                                      "#{recipients[0].id}, " +
                                      " #{recipients[1].id}"
                                  }
      end
    end
    assert_response :created
    assert_not_nil assigns(:message)
    message = assigns(:message)
    assert_equal sender, message.sender
    assert_equal "hello world!", message.subject
    assert_equal "foo bar", message.content
    assert message.recipients.include?(recipients[0])
    assert message.recipients.include?(recipients[1])
    # testing response content
    assert_select "sent_message:root[id=#{message.id}]" +
        "[href=#{sent_message_url(message)}]" do
      assert_select "subject", message.subject
      assert_select "content", message.content
      assert_select "created_at", message.created_at.xmlschema
      assert_select "recipients" do
        message.recipients.each do |recipient|
          assert_select "recipient[id=#{recipient.id}]" +
              "[href=#{user_url(recipient)}]"
        end
      end
    end
    # email fwd
    assert_equal 2, @emails.size
    recipients.each do |r|
      assert @emails.map { |e| e.to[0] }.include?(r.email)
    end
  end


  test "send message, recipients with names" do
    sender = users(:mickey_mouse)
    set_authorization_header(sender.nick_name, sender.password)
    #
    recipients = [users(:donald_duck), users(:user_N)]
    assert_difference('Message.count', 1) do
      assert_difference('ForwardedMessage.count', 2) do
        post :create, :message => { :subject => "hello world!",
                                    :content => "foo bar",
                                    :recipients_ids_string =>
                          "#{recipients[0].name}<#{recipients[0].id}>, " +
                          "#{recipients[1].name}<#{recipients[1].id}>"
                                  }
      end
    end
    assert_response :created
  end


  test "send message, format html" do
    sender = users(:mickey_mouse)
    set_authorization_header(sender.nick_name, sender.password)
    #
    recipients = [users(:donald_duck), users(:user_N)]
    recipients[1].forward_messages_to_mail = false
    recipients[1].save!
    assert_difference('Message.count', 1) do
      assert_difference('ForwardedMessage.count', 2) do
        post :create, :message => { :subject => "hello world!",
                                    :content => "foo bar",
                                    :recipients_ids_string =>
                                      "#{recipients[0].id}," +
                                      "#{recipients[1].id}"
                                  },
                                  :format => 'html'
      end
    end
    assert_redirected_to sent_messages_url
    assert_equal I18n.t('notices.message_sent'), flash[:notice]
    assert_not_nil assigns(:message)
    message = assigns(:message)
    assert_equal sender, message.sender
    assert_equal "hello world!", message.subject
    assert_equal "foo bar", message.content
    assert message.recipients.include?(recipients[0])
    assert message.recipients.include?(recipients[1])
    # email fwd
    assert_equal 1, @emails.size
    assert @emails.map { |e| e.to[0] }.include?(recipients[0].email)
  end


  test "cannot send message without credentials" do
    post :create, :message => { :subject => "foo",
                                :content => "bar",
                                :recipients_ids_string =>
                                  "#{users(:mickey_mouse).id}"
                              }
    assert_response :unauthorized
    assert_equal 0, @emails.size
  end


  test "send_message with wrong params 1" do
    sender = users(:mickey_mouse)
    set_authorization_header(sender.nick_name, sender.password)
    #
    recipients = [users(:donald_duck), sender] # INVALID RECIPIENT
    assert_difference('Message.count', 0) do
      assert_difference('ForwardedMessage.count', 0) do
        post :create, :message => { :subject => "hello world!",
                                    :content => "foo bar",
                                    :recipients_ids_string =>
                                      "#{recipients[0].id}," +
                                      "#{recipients[1].id}"
                                  }
      end
    end
    assert_response :unprocessable_entity
    assert_equal 0, @emails.size
  end


  test "send_message with wrong params 2" do
    sender = users(:mickey_mouse)
    set_authorization_header(sender.nick_name, sender.password)
    #
    assert_difference('Message.count', 0) do
      assert_difference('ForwardedMessage.count', 0) do
        # UNEXISTENT RECIPIENTS
        post :create, :message => { :subject => "hello world!",
                                    :content => "foo bar",
                                    :recipients_ids_string => "-1,-2"
                                  }
      end
    end
    assert_response :unprocessable_entity
    assert_equal 0, @emails.size
  end


  test "send_message with wrong params 2, format html" do
    sender = users(:mickey_mouse)
    set_authorization_header(sender.nick_name, sender.password)
    #
    assert_difference('Message.count', 0) do
      assert_difference('ForwardedMessage.count', 0) do
        # UNEXISTENT RECIPIENTS
        post :create, :message => { :subject => "hello world!",
                                    :content => "foo bar",
                                    :recipients_ids_string => "-1,-2"
                                  },
                                  :format => 'html'
      end
    end
    assert_template 'new'
    assert_equal 0, @emails.size
  end


  # GET /messages/new

  test "get new" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :new
    assert_response :success
    assert_equal 'text/html', @response.content_type
  end


  test "cannot get new without credentials" do
    get :new
    assert_response :unauthorized
  end

end
