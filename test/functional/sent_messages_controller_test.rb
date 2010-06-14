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

class SentMessagesControllerTest < ActionController::TestCase

  # GET /sent_messages

  test "get index" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    get :index, :format => 'xml'
    assert_response :success
    assert_equal 'application/xml', @response.content_type
    assert_not_nil assigns(:messages)
    messages = assigns(:messages)
    assert_equal user.sent_messages.find(:all,
                                         :conditions => "deleted = false"),
                                         messages
    # testing response content
    assert_select "sent_messages:root[user_id=#{user.id}]" +
        "[user_href=#{user_url(user)}]" do
      messages.each do |m|
        assert_select "message[id=#{m.id}][href=#{sent_message_url(m)}]" do
          assert_select "subject", m.subject
          assert_select "recipients" do
            m.recipients.each do |recipient|
              assert_select "recipient[id=#{recipient.id}]" +
                  "[href=#{user_url(recipient)}]"
            end
          end
        end
      end
    end
  end


  test "get index format html" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    get :index
    assert_response :success
    assert_equal 'text/html', @response.content_type
    assert_not_nil assigns(:messages)
  end


  test "deleted messages are not in the index" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    get :index, :format => 'xml'
    messages = assigns(:messages)
    assert !messages.include?(messages(:three))
  end


  test "cannot get index without credentials" do
    get :index
    assert_response :unauthorized
  end


  # GET /sent_messages/:id

  test "get show" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    get :show, :format => 'xml', :id => messages(:two).id
    assert_response :success
    assert_equal 'application/xml', @response.content_type
    assert_not_nil assigns(:message)
    message = assigns(:message)
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
  end


  test "get show by xhr" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    xhr(:get, :show, :id => messages(:two).id)
    assert_response :success
    assert_equal 'text/javascript', @response.content_type
  end


  test "show deleted message respond not found" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    get :show, :id => messages(:three).id
    assert_response :not_found
  end


  test "cannot get show without credentials" do
    get :show, :id => messages(:one).id
    assert_response :unauthorized
  end


  test "cannot get someone's other message" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => messages(:one).id # it is of mickey mouse
    assert_response :forbidden
  end


  test "get show with wrong id" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    get :show, :id => -1
    assert_response :not_found
  end


  # DELETE /sent_messages/:id

  test "delete a message" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    delete :destroy, :id => messages(:one).id
    assert_response :ok
    assert_not_nil assigns(:message)
    message = assigns(:message)
    assert message.deleted?
  end


  test "delete a message by xhr" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    xhr(:delete, :destroy, :id => messages(:one).id)
    assert_response :success
    assert_equal 'text/javascript', @response.content_type
    assert_not_nil assigns(:message)
    message = assigns(:message)
    assert message.deleted?
  end


  test "cannot delete a message without credentials" do
    delete :destroy, :id => messages(:one).id
    assert_response :unauthorized
  end


  test "cannot delete someone's other message" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    delete :destroy, :id => messages(:one).id
    assert_response :forbidden
  end


  test "delete with wrong id" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    delete :destroy, :id => -1
    assert_response :not_found
  end

end
