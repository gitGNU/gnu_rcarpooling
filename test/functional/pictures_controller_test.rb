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

class PicturesControllerTest < ActionController::TestCase

  # GET /users/:user_id/picture/edit


  test "get pict form of unexistent user" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :edit, :user_id => -1
    assert_response :not_found
  end


  test "cannot get pict form of someone's other" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :edit, :user_id => users(:mickey_mouse).id
    assert_response :forbidden
  end


  test "cannot get pict form without credentials" do
    get :edit, :user_id => users(:mickey_mouse).id
    assert_response :unauthorized
  end


  test "get pict form" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :edit, :user_id => user.id
    assert_response :success
    assert_equal 'text/html', @response.content_type
  end


  # GET /users/:user_id/picture


  test "cannot get picture without credentials" do
    get :show, :user_id => users(:mickey_mouse).id
    assert_response :unauthorized
  end


  test "cannot get picture of someone who does not show" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    user = users(:mickey_mouse)
    assert ! user.shows_picture?
    get :show, :user_id => user.id
    assert_response :forbidden
  end


  test "get picture of someone who shows" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    user = users(:mickey_mouse)
    #
    pict = UserPicture.new
    pict.user = user
    pict.uploaded_data = fixture_file_upload("files/image.png",
                                             "image/png")
    pict.save!
    #
    assert user.shows_picture?
    get :show, :user_id => user.id
    assert_response :success
    assert_equal 'image/png', @response.content_type
  end


  test "get picture of unexistent user" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :show, :user_id => -1
    assert_response :not_found
  end


  test "user has no picture" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :user_id => user.id
    assert_response :not_found
  end


  test "get a picture" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    pict = UserPicture.new
    pict.user = user
    pict.uploaded_data = fixture_file_upload("files/image.png", "image/png")
    pict.save!
    #
    get :show, :user_id => user.id
    assert_response :success
    assert_equal "image/png", @response.content_type
    #
    UserPicture.destroy_all
  end


  # PUT /users/:id/picture


  test "put picture of unexistent user" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    put :update, :user_id => -1
    assert_response :not_found
  end


  test "cannot put picture of someone's other" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    put :update, :user_id => users(:mickey_mouse).id
    assert_response :forbidden
  end


  test "cannot put picture without credentials" do
    put :update, :user_id => users(:mickey_mouse).id
    assert_response :unauthorized
  end


  test "put a picture" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('UserPicture.count', 1) do
      assert_difference('DbFile.count', 1) do
        put :update, :format => 'xml', :user_id => user.id,
            :picture => {
              :uploaded_data => fixture_file_upload("files/image.png",
                                                  "image/png")
                        }
      end
    end
    assert_response :no_content
    #
    UserPicture.destroy_all
  end


  test "put a picture format html" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('UserPicture.count', 1) do
      assert_difference('DbFile.count', 1) do
        put :update, :user_id => user.id,
            :picture => {
                  :uploaded_data => fixture_file_upload("files/image.png",
                                                  "image/png")
                        }
      end
    end
    assert_redirected_to user_url(user)
    #
    UserPicture.destroy_all
  end


  test "put a picture to a user who already owns one" do
    user = users(:donald_duck)
    #
    pict = UserPicture.new
    pict.user = user
    pict.uploaded_data = fixture_file_upload("files/image.png", "image/png")
    pict.save!
    #
    set_authorization_header(user.nick_name, user.password)
    assert_difference('UserPicture.count', 0) do
      assert_difference('DbFile.count', 0) do
        put :update, :format => 'xml', :user_id => user.id, :picture => {
            :uploaded_data => fixture_file_upload("files/image.png",
                                                  "image/png")}
      end
    end
    assert_response :no_content
    #
    UserPicture.destroy_all
  end


  test "put wrong data for picture" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('UserPicture.count', 0) do
      assert_difference('DbFile.count', 0) do
        put :update, :format => 'xml', :user_id => user.id, :picture => {
            :uploaded_data => fixture_file_upload("files/text_file.txt",
                                                  "text/plain") }
      end
    end
    assert_response :unprocessable_entity
    assert_equal 'application/xml', @response.content_type
  end


  test "put wrong data for picture format html" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    assert_difference('UserPicture.count', 0) do
      assert_difference('DbFile.count', 0) do
        put :update, :user_id => user.id,
            :picture => {
                :uploaded_data => fixture_file_upload("files/text_file.txt",
                                                  "text/plain")
                        }
      end
    end
    assert_equal 'text/html', @response.content_type
    assert_template "edit"
    assert_select ".errors"
  end


  # DELETE /users/:id/picture


  test "delete picture of unexistent user" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    delete :destroy, :user_id => -1
    assert_response :not_found
  end


  test "cannot delete picture of someone's other" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    delete :destroy, :user_id => users(:mickey_mouse).id
    assert_response :forbidden
  end


  test "cannot delete picture without credentials" do
    delete :destroy, :user_id => users(:mickey_mouse).id
    assert_response :unauthorized
  end


  test "delete picture but user hasn't" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    delete :destroy, :user_id => user.id
    assert_response :not_found
  end


  test "delete a picture" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    pict = UserPicture.new
    pict.user = user
    pict.uploaded_data = fixture_file_upload("files/image.png",
                                             "image/png")
    pict.save!
    #
    assert_difference('UserPicture.count', -1) do
      assert_difference('DbFile.count', -1) do
        delete :destroy, :format => 'xml', :user_id => user.id
      end
    end
    assert_response :ok
    #
    UserPicture.destroy_all
  end


  test "delete a picture format html" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    pict = UserPicture.new
    pict.user = user
    pict.uploaded_data = fixture_file_upload("files/image.png",
                                             "image/png")
    pict.save!
    #
    assert_difference('UserPicture.count', -1) do
      assert_difference('DbFile.count', -1) do
        delete :destroy, :user_id => user.id
      end
    end
    assert_redirected_to user_url(user)
    #
    UserPicture.destroy_all
  end


end
