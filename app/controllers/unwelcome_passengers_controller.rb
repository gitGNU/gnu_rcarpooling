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

class UnwelcomePassengersController < ApplicationController


  before_filter :authenticate, :find_user


  # GET /users/:user_id/unwelcome_passengers
  def index
    @unwelcome_passengers = @user.passengers_in_black_list
  end


  # GET /users/:user_id/unwelcome_passengers/:id
  def show
    @unwelcome_passenger =
        @user.passengers_in_black_list.find_by_id(params[:id])
    if @unwelcome_passenger
      respond_to do |format|
        format.xml
      end
    else
      head :not_found
    end
  end


  # POST /users/:user_id/unwelcome_passengers
  def create
    @unwelcome_passenger = User.find_by_id(params[:unwelcome_user])
    entry = BlackListPassengersEntry.new(:user => @user,
                                         :passenger => @unwelcome_passenger)
    if entry.save
      if request.xhr?
        render :update do |page|
          page.replace 'users_in_black_list_set',
              :partial => "partials/black_lists/users_in_black_list",
              :object => @user.passengers_in_black_list.map { |d| [d,
                            user_unwelcome_passenger_url(:user_id => @user.id,
                                                      :id => d.id)]},
              :locals => { :url_post => user_unwelcome_passengers_url(
                                              :user_id => @user.id),
                :empty_message => I18n.t('users.no_passengers_in_black_list')}
        end
      else
        respond_to do |format|
          format.xml { render :action => "show",
                       :status => :created,
                       :location => user_unwelcome_passenger_url(
                                    :id => @unwelcome_passenger.id,
                                    :user_id => @user.id)}
        end
      end
    else
      respond_to do |format|
        format.xml { render :xml => entry.errors,
                      :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /users/:user_id/unwelcome_passengers/:id
  def destroy
    @unwelcome_passenger = @user.passengers_in_black_list.find_by_id(
      params[:id])
    if @unwelcome_passenger
      entry = @user.black_list_passengers_entries.
        find_by_user_id_and_passenger_id(@user.id, @unwelcome_passenger.id)
      entry.destroy
      if request.xhr?
        render :update do |page|
          page.replace 'users_in_black_list_set',
              :partial => "partials/black_lists/users_in_black_list",
              :object => @user.passengers_in_black_list.map { |d| [d,
                            user_unwelcome_passenger_url(:user_id => @user.id,
                                                      :id => d.id)]},
              :locals => { :url_post => user_unwelcome_passengers_url(
                                              :user_id => @user.id),
                :empty_message => I18n.t('users.no_passengers_in_black_list')}
        end
      else
        head :ok
      end
    else
      head :not_found
    end
  end


  private


  def find_user
    @user = nil
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
    if @user
      if @user.id != params[:uid]
        head :forbidden
      end
    else
      head :not_found
    end
  end

end
