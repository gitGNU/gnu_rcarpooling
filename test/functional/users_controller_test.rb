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

class UsersControllerTest < ActionController::TestCase

  def setup
    AuthenticatorFactory.set_factory(AuthenticatorFactoryMock.new)
  end


  def tear_down
    AuthenticatorFactory.clear_factory
  end


  test "get a user" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :id => user.id
    assert_response :success
    assert_not_nil assigns(:user)
  end


  test "cannot get a user without credentials" do
    get :show, :id => users(:donald_duck).id
    assert_response :unauthorized
  end


  test "get a non-existent user" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :id => -1
    assert_response :not_found
  end


  test "can get only my data" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :show, :id => users(:mickey_mouse).id
    assert_response :forbidden
  end


  test "get ME" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    get :me
    assert_response :temporary_redirect
    assert_redirected_to user
  end


  test "cannot get ME without credentials" do
    get :me
    assert_response :unauthorized
  end


  test "user xml contents" do
    user = users(:donald_duck)
    user.drivers_in_black_list << users(:mickey_mouse)
    user.passengers_in_black_list << users(:mickey_mouse)
    user.save!
    set_authorization_header(user.nick_name, user.password)
    get :show, :format => "xml", :id => user.id
    assert_response :success
    # testing response content
    assert_select "user:root[id=#{user.id}][href=#{user_url(user)}]" do
      assert_select "first_name", user.first_name
      assert_select "last_name", user.last_name
      assert_select "sex", user.sex
      assert_select "nick_name", user.nick_name
      assert_select "email", user.email
      assert_select "lang", user.lang
      assert_select "max_foot_length", user.max_foot_length.to_s
      # black list
      assert_select "black_list" do
        user.drivers_in_black_list.each do |driver|
          assert_select "user[id=#{driver.id}]" +
              "[href=#{user_url(driver)}][rel=driver]" do
            assert_select "first_name", driver.first_name
            assert_select "last_name", driver.last_name
            assert_select "nick_name", driver.nick_name
          end
        end # loop on drivers
        user.passengers_in_black_list.each do |pass|
          assert_select "user[id=#{pass.id}]" +
              "[href=#{user_url(pass)}][rel=passenger]" do
            assert_select "first_name", pass.first_name
            assert_select "last_name", pass.last_name
            assert_select "nick_name", pass.nick_name
          end
        end # loop on passengers
      end
    end
  end


  test "get a form to create a new user" do
    get :new
    assert_response :success
    assert_equal "text/html", @response.content_type
  end


  # PUT /users/:id


  test "update a user, format XML" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    put :update, :format => "xml",
                 :id => user.id, :user => {:first_name => "Minnie",
                                           :last_name => "MinnieLast",
                                           :email => "new@email",
                                           :sex => "F",
                                           :max_foot_length => 1000,
                                           :language_id =>
                                              languages(:it).id
                                          }
    assert_response :success
    assert_not_nil assigns(:user)
    # check the entity-body returned
    user_updated = assigns(:user)
    assert_equal "Minnie", user_updated.first_name
    assert_equal "MinnieLast", user_updated.last_name
    assert_equal "new@email", user_updated.email
    assert_equal "F", user_updated.sex
    assert_equal 1000, user_updated.max_foot_length
    assert_equal languages(:it), user_updated.language
  end


  test "update a user, format HTML" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    put :update, :format => "html",
                :id => user.id, :user => {:first_name => "Minnie",
                                           :last_name => "MinnieLast",
                                           :email => "new@email",
                                           :sex => "F",
                                           :max_foot_length => 1000,
                                           :language_id =>
                                              languages(:it).id
                                          }
    assert_redirected_to user_url(user)
    assert_not_nil assigns(:user)
    # check the entity-body returned
    user_updated = assigns(:user)
    assert_equal "Minnie", user_updated.first_name
    assert_equal "MinnieLast", user_updated.last_name
    assert_equal "new@email", user_updated.email
    assert_equal "F", user_updated.sex
    assert_equal 1000, user_updated.max_foot_length
    assert_equal languages(:it), user_updated.language

  end


  test "cannot update a user without credentials" do
    user = users(:mickey_mouse)
    #
    put :update, :id => user.id, :user => {:first_name => "Minnie",
                                           :last_name => "MinnieLast",
                                           :email => "new@email",
                                           :sex => "F",
                                           :max_foot_length => 1000,
                                           :language_id =>
                                              languages(:it).id
                                          }
    assert_response :unauthorized
  end


  test "cannot update someone's other" do
    user = users(:mickey_mouse)
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    #
    put :update, :id => user.id, :user => {:first_name => "Minnie",
                                           :last_name => "MinnieLast",
                                           :email => "new@email",
                                           :sex => "F",
                                           :max_foot_length => 1000,
                                           :language_id =>
                                              languages(:it).id
                                          }
    assert_response :forbidden
  end


  test "updating a non-existent user" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    put :update, :id => -1, :user => {:first_name => "Minnie",
                                      :last_name => "MinnieLast",
                                      :email => "new@email",
                                      :sex => "F",
                                      :max_foot_length => 1000,
                                      :language_id =>
                                            languages(:it).id
                                     }
    assert_response :not_found
  end


  test "updating with invalid params, format XML" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    put :update, :format => "xml",
                 :id => user.id, :user => {:first_name => "",
                                           :last_name => "MinnieLast",
                                           :email => "new@email",
                                           :sex => "F",
                                           :max_foot_length => 1000,
                                           :language_id =>
                                              languages(:it).id
                                          }
    assert_response :unprocessable_entity
  end


  test "updating with invalid params, format HTML" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    put :update, :format => "html",
                 :id => user.id, :user => {:first_name => "",
                                           :last_name => "MinnieLast",
                                           :email => "new@email",
                                           :sex => "F",
                                           :max_foot_length => 1000,
                                           :language_id =>
                                              languages(:it).id
                                          }
    assert_template "users/edit.html.erb"
    assert_select ".errors"
  end


  test "password and other fields don't change" do
    user = users(:mickey_mouse)
    set_authorization_header(user.nick_name, user.password)
    #
    put :update, :id => user.id, :user => {:nick_name => "NEW_NICK",
                                           :password => "NEW_PASS",
                                           :score => 9999999
                                          }
    assert_response :success
    assert_not_nil assigns(:user)
    # check the entity-body returned
    user_updated = assigns(:user)
    # nothing was changed :P
    assert_equal user, user_updated
  end


  # POST /users


  test "create a user, format XML" do
    requester = potential_users(:uncle_scrooge)
    assert_difference('User.count', 1) do
      post :create, :format => "xml",
                    :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => requester.account_name,
                              :password => requester.password
                            }
    end
    assert_response :created
    assert_not_nil assigns(:user)
    uncle_scrooge = assigns(:user)
    assert_equal user_url(uncle_scrooge), @response.location
    # nick name and password are the same of params sent
    assert_equal requester.account_name, uncle_scrooge.nick_name
    assert_equal requester.password, uncle_scrooge.password
  end


  test "create a user, format HTML" do
    requester = potential_users(:uncle_scrooge)
    assert_difference('User.count', 1) do
      post :create, :format => "html",
                    :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => requester.account_name,
                              :password => requester.password
                            }
    end
    assert_not_nil assigns(:user)
    uncle_scrooge = assigns(:user)
    assert_redirected_to user_url(uncle_scrooge)
    # check session
    assert_equal uncle_scrooge.id, session[:uid]
    # nick name and password are the same of params sent
    assert_equal requester.account_name, uncle_scrooge.nick_name
    assert_equal requester.password, uncle_scrooge.password
  end


  test "cannot create a user without credentials" do
    assert_difference('User.count', 0) do
      post :create, :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000
                            }
    end
    assert_response :unprocessable_entity
  end


  test "cannot create a user without credentials, format html" do
    assert_difference('User.count', 0) do
      post :create, :format => "html",
                              :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000
                            }
    end
    assert_template "new"
    assert_select ".errors"
    assert !session[:uid]
  end


  test "cannot create a user if my account is already registered" do
    user = users(:mickey_mouse) # already registered
    assert_difference('User.count', 0) do
      post :create, :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => user.nick_name,
                              :password => user.password
                            }
    end
    assert_response :unprocessable_entity
  end


  test "cannot create a user if my account is already registered, format html" do
    user = users(:mickey_mouse) # already registered
    assert_difference('User.count', 0) do
      post :create, :format => "html",
                    :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => user.nick_name,
                              :password => user.password
                            }
    end
    assert_template "new"
    assert_select ".errors"
    assert !session[:uid]
  end


  test "cannot create a user with wrong params, format XML" do
    requester = potential_users(:uncle_scrooge)
    assert_difference('User.count', 0) do
      post :create, :format => "xml",
                  :user => {# first name missed
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => requester.account_name,
                              :password => requester.password
                            }
    end
    assert_response :unprocessable_entity
  end


  test "cannot create a user with wrong params, format HTML" do
    requester = potential_users(:uncle_scrooge)
    assert_difference('User.count', 0) do
      post :create, :format => "html",
                  :user => {# first name missed
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => requester.account_name,
                              :password => requester.password
                            }
    end
    assert_template "users/new.html.erb"
    assert_select ".errors"
    assert !session[:uid]
  end


  test "cannot create a user if not a potential user, format XML" do
    assert_difference('User.count', 0) do
      post :create, :format => "xml",
                    :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => "foo",
                              :password => "bar"
                            }
    end
    assert_response :unprocessable_entity
  end


  test "cannot create a user if not a potential user, format html" do
    assert_difference('User.count', 0) do
      post :create, :format => "html",
                    :user => {:first_name => "Uncle",
                              :last_name => "Scrooge",
                              :email => "uncle@scrooge",
                              :sex => "M",
                              :language_id => languages(:it).id,
                              :max_foot_length => 1000,
                              :nick_name => "foo",
                              :password => "bar"
                            }
    end
    assert_template "users/new.html.erb"
    assert_select ".errors"
    assert !session[:uid]
  end


  # GET /users/:id/edit


  test "form for editing user's data" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :edit, :id => user.id
    assert_response :success
    assert_not_nil assigns(:user)
    assert_equal "text/html", @response.content_type
  end


  test "cannot get the form for editing without credentials" do
    get :edit, :id => users(:donald_duck).id
    assert_response :unauthorized
  end


  test "cannot get someone's other form for editing" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :edit, :id => users(:mickey_mouse).id
    assert_response :forbidden
  end


  test "get a non-existent user's form for editing" do
    user = users(:donald_duck)
    set_authorization_header(user.nick_name, user.password)
    #
    get :edit, :id => -1
    assert_response :not_found
  end


  # GET /users/search


  test "search" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    get :search, :name => "#{users(:mickey_mouse).last_name}"
    assert_response :success
    assert_not_nil assigns(:users)
    users = assigns(:users)
    assert users.size > 0
  end


  test "cannot search without credentials" do
    get :search, :name => "bla"
    assert_response :unauthorized
  end


  test "search1" do
    set_authorization_header(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    u = users(:mickey_mouse)
    get :search, :name => "#{u.first_name.downcase} #{u.last_name.upcase}"
    assert_response :success
    assert_not_nil assigns(:users)
    users = assigns(:users)
    assert_equal u, users[0]
  end


  # GET /login
  test "get login form" do
    get :login
    assert_response :success
    assert_equal "text/html", @response.content_type
    assert_template "login"
  end


  # POST /login


  test "post login" do
    user = users(:mickey_mouse)
    post :login, :nick_name => user.nick_name, :password => user.password
    assert_redirected_to home_url
    assert_equal user.id, session[:uid]
    assert_equal I18n.t('notices.login_succeded'), flash[:notice]
  end


  test "post login with invalid credentials" do
    post :login, :nick_name => "foo", :password => "bar"
    assert_redirected_to login_get_url
    assert !session[:uid]
    assert_equal I18n.t('notices.login_failed'), flash[:notice]
  end


  test "cannot login if not registered" do
    pu = potential_users(:uncle_scrooge)
    post :login, :nick_name => pu.account_name, :password => pu.password
    assert_redirected_to login_get_url
    assert !session[:uid]
    assert_equal I18n.t('notices.login_failed'), flash[:notice]
  end


  test "re-login with invalid credentials" do
    user = users(:donald_duck)
    post :login, { :nick_name => "foo", :password => "bar"},
        {:uid => user.id}
    assert_redirected_to login_get_url
    assert !session[:uid]
    assert_equal I18n.t('notices.login_failed'), flash[:notice]
  end


  # POST /logout

  test "logout" do
    user = users(:donald_duck)
    post :logout, {}, {:uid => user.id}
    assert_redirected_to home_url
    assert !session[:uid]
    assert_equal I18n.t('notices.logout_succeded'), flash[:notice]
  end

end
