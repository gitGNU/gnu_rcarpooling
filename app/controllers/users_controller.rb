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

class UsersController < ApplicationController


  before_filter :authenticate, :except => ["new", "create", "login"]


  # GET /users
  def index
    if request.xhr?
      query = params[:q]
      @users = []
      # performing query
      if query and query.length > 0
        if params[:last_name]
          @users.concat(User.find_all_by_last_name(query))
        end
        if params[:nick_name]
          @users.concat(User.find_all_by_nick_name(query))
        end
      end
      #
      render :update do |page|
        page.replace_html 'users_search_results',
            :partial => "search_results"
      end
    else
      render
    end
  end


  # GET /users/:id
  def show
    @user = User.find_by_id(params[:id])
    if @user
      if params[:uid] == @user.id
        respond_to do |format|
          format.xml
          format.html
        end
      else
        @requester = User.find(params[:uid])
        respond_to do |format|
          format.xml do
            if @user.visible_by_all? or (@user.visible_only_by_known? and
                                         @user.knows?(@requester))
              render :template => 'users/show_public.xml.builder'
            else
              head :forbidden
            end
          end
          format.html do
            if @user.visible_by_all? or (@user.visible_only_by_known? and
                                         @user.knows?(@requester))
              render :template => 'users/show_public.html.erb'
            else
              render :template => 'users/show_forbidden.html.erb'
            end
          end
        end
      end
    else
      head :not_found
    end
  end


  # GET /users/me
  def me
    @user = User.find(params[:uid])
    @last_demand = @user.demands.find(:last)
    @last_offering = @user.offerings.find(:last)
  end


  # PUT /users/:id
  def update
    @user = User.find_by_id(params[:id])
    if @user
      if params[:uid] == @user.id
        if params[:user]
          data = params[:user]
          @user.email = data[:email] if data[:email]
          @user.sex = data[:sex] if data[:sex]
          if data[:max_foot_length]
            @user.max_foot_length = data[:max_foot_length]
          end
          if data[:language_id]
            @user.language = Language.find_by_id(data[:language_id])
          end
          if data[:telephone_number]
            @user.telephone_number = data[:telephone_number]
          end
          if data[:vehicle_registration_plate]
            @user.vehicle_registration_plate =
                data[:vehicle_registration_plate]
          end
          @user.car_details = data[:car_details] if data[:car_details]
          if data[:forward_messages_to_mail]
            @user.forward_messages_to_mail = data[:forward_messages_to_mail]
          end
          if data[:forward_ads_to_mail]
            @user.forward_ads_to_mail = data[:forward_ads_to_mail]
          end
          if data[:public_profile_visibility]
            @user.public_profile_visibility = data[:public_profile_visibility]
          end
        end
        # now save
        if @user.save
          respond_to do |format|
            format.xml { render :action => :show }
            format.html { flash[:notice] = I18n.t('notices.user_updated')
                          redirect_to @user }
          end
        else
          respond_to do |format|
            format.xml { render :xml => @user.errors,
                         :status => :unprocessable_entity }
            format.html { render :action => "edit" }
          end
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  # POST /users
  def create
    @user = User.new
    if params[:user]
      data = params[:user]
      @user.first_name = data[:first_name]
      @user.last_name = data[:last_name]
      @user.email = data[:email]
      @user.sex = data[:sex]
      @user.language = Language.find_by_id(data[:language_id])
      @user.max_foot_length = data[:max_foot_length] if data[:max_foot_length]
      @user.telephone_number = data[:telephone_number]
      @user.vehicle_registration_plate = data[:vehicle_registration_plate]
      # account credentials
      @user.nick_name = data[:nick_name]
      @user.password = data[:password]
      authenticator = Authenticator.new(data[:nick_name], data[:password])
      if -1 != authenticator.authenticate
        @user.errors.add(:nick_name, I18n.t("activerecord.errors.messages." +
                                            "user.wrong_credential"))
        @user.errors.add(:password, I18n.t("activerecord.errors.messages." +
                                           "user.wrong_credential"))
      end
    end
    if @user.errors.empty? and @user.save
      respond_to do |format|
        format.xml { render :action => :show, :status => :created,
                     :location => @user }
        format.html { flash[:notice] = I18n.t('notices.user_created')
                      session[:uid] = @user.id
                      redirect_to @user }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @user.errors,
                     :status => :unprocessable_entity }
        format.html { render :action => "new" }
      end
    end
  end


  # GET /users/:id/edit
  def edit
    @user = User.find_by_id(params[:id])
    if @user
      if @user.id != params[:uid]
        head :forbidden
      else
        respond_to do |format|
          format.html
        end
      end
    else
      head :not_found
    end
  end


  # GET /users/new
  def new
    @user = User.new
  end


  # GET and POST /login
  def login
    if request.get?
      render
    elsif request.post?
      authenticator = Authenticator.new(params[:nick_name],
                                        params[:password])
      user_id = authenticator.authenticate
      if !user_id or -1 == user_id
        # invalid
        session[:uid] = nil
        flash[:notice] = I18n.t 'notices.login_failed'
        redirect_to login_url
      else
        # valid
        session[:uid] = user_id
        flash[:notice] = I18n.t 'notices.login_succeded'
        redirect_to home_url
      end
    end
  end


  # POST /logout
  def logout
    session[:uid] = nil
    flash[:notice] = I18n.t 'notices.logout_succeded'
    redirect_to home_url
  end


end
