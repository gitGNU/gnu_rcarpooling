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

class UnwelcomeDriversController < ApplicationController


  before_filter :authenticate, :find_user


  # GET /users/:user_id/unwelcome_drivers/:id
  def show
    @unwelcome_driver =
        @user.black_list_drivers_entries.find_by_id(params[:id])
    if @unwelcome_driver
      respond_to do |format|
        format.xml
      end
    else
      head :not_found
    end
  end


  # POST /users/:user_id/unwelcome_drivers
  def create
    @unwelcome_driver = BlackListDriversEntry.new
    @unwelcome_driver.user = @user
    @unwelcome_driver.driver = User.find_by_id(
      params[:unwelcome_driver][:id]) if params[:unwelcome_driver]
    if @unwelcome_driver.save
      respond_to do |format|
        format.xml { render :action => "show",
                     :status => :created,
                     :location => user_unwelcome_driver_url(
                                :id => @unwelcome_driver.id,
                                :user_id => @unwelcome_driver.user.id)}
      end
    else
      respond_to do |format|
        format.xml { render :xml => @unwelcome_driver.errors,
                      :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /users/:user_id/unwelcome_drivers/:id
  def destroy
    @unwelcome_driver = BlackListDriversEntry.find_by_id(
      params[:id])
    if @unwelcome_driver
      @unwelcome_driver.destroy
      head :ok
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
