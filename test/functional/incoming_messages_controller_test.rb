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

class IncomingMessagesControllerTest < ActionController::TestCase

  # GET /incoming_messages

  test "get index" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :index, :format => 'xml'
    assert_response :success
    assert_equal 'application/xml', @response.content_type
    assert_not_nil assigns(:incoming_messages)
    mess = assigns(:incoming_messages)
    assert_equal user.incoming_messages.find(:all,
                                          :conditions => "deleted = false"),
                                          mess
    # testing response content
    assert_select "incoming_messages:root[user_id=#{user.id}]" +
        "[user_href=#{user_url(user)}]" do
      mess.each do |m|
        assert_select "incoming_message[id=#{m.id}]" +
            "[href=#{incoming_message_url(m)}]" do
          assert_select "subject", m.subject
          assert_select "sender[id=#{m.sender.id}]" +
              "[href=#{user_url(m.sender)}]"
        end
      end
    end
  end


  test "get index, format html" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :index
    assert_response :success
    assert_equal 'text/html', @response.content_type
  end


  test "get index by xhr" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    xhr(:get, :index)
    assert_response :success
    assert_equal 'text/javascript', @response.content_type
  end


  test "deleted messages are not in index" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :index, :format => 'xml'
    incoming_messages = assigns(:incoming_messages)
    assert !incoming_messages.include?(forwarded_messages(:message_deleted))
  end


  test "cannot get index without credentials" do
    get :index
    assert_response :unauthorized
  end


  # GET /incoming_messages/:id

  test "get show" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    assert !forwarded_messages(:one).seen?
    get :show, :id => forwarded_messages(:one).id
    assert_response :success
    assert_equal 'application/xml', @response.content_type
    assert_not_nil assigns(:incoming_message)
    m = assigns(:incoming_message)
    assert m.seen?
    # testing response content
    assert_select "incoming_message:root[id=#{m.id}]" +
        "[href=#{incoming_message_url(m)}]" do
      assert_select "sender[id=#{m.sender.id}]" +
          "[href=#{user_url(m.sender)}]"
      assert_select "sent_at", m.created_at.xmlschema
      assert_select "subject", m.subject
      assert_select "content", m.content
    end
  end


  test "get show by xhr" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    assert !forwarded_messages(:one).seen?
    xhr(:get, :show, :id => forwarded_messages(:one).id)
    assert_response :success
    assert_equal 'text/javascript', @response.content_type
  end


  test "get show not found if message was deleted" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :show, :id => forwarded_messages(:message_deleted).id
    assert_response :not_found
  end


  test "cannot get show without credentials" do
    get :show, :id => forwarded_messages(:one).id
    assert_response :unauthorized
  end


  test "cannot get someone's other message" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    get :show, :id => forwarded_messages(:one).id # it is of donald duck
    assert_response :forbidden
  end


  test "get show with wrong id" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :id => -1
    assert_response :not_found
  end


  # DELETE /incoming_messages/:id

  test "delete an incoming message" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    delete :destroy, :id => forwarded_messages(:one).id
    assert_response :ok
    assert_not_nil assigns(:incoming_message)
    m = assigns(:incoming_message)
    assert m.deleted?
  end


  test "delete an incoming message by xhr" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    xhr(:delete, :destroy, :id => forwarded_messages(:one).id)
    assert_response :success
    assert_equal 'text/javascript', @response.content_type
  end


  test "cannot delete without credentials" do
    delete :destroy, :id => forwarded_messages(:one).id
    assert_response :unauthorized
  end


  test "cannot delete someone's other message" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    delete :destroy, :id => forwarded_messages(:one).id
    assert_response :forbidden
  end


  test "delete with wrong id" do
    set_authorization_header(users(:mickey_mouse).nick_name,
                             users(:mickey_mouse).password)
    delete :destroy, :id => -1
    assert_response :not_found
  end

end
