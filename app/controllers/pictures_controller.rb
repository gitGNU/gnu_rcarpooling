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

class PicturesController < ApplicationController

  before_filter :authenticate, :find_user


  # GET /users/:user_id/picture
  def show
    if @user.picture
      pict = @user.picture
      send_data pict.current_data, :type => pict.content_type,
                :disposition => 'inline', :filename => pict.filename
    else
      head :not_found
    end
  end


  # GET /users/:user_id/edit
  def edit
  end


  # PUT /users/:user_id/picture
  def update
    @user.picture.destroy if @user.picture
    @user.picture = UserPicture.new(params[:picture])
    @picture = @user.picture
    if @picture.save
      respond_to do |format|
        format.xml { head :no_content }
        format.html { flash[:notice] = I18n.t 'notices.picture_uploaded'
                      redirect_to user_url(@user) }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @picture.errors,
                      :status => :unprocessable_entity }
        format.html { render :action => "edit" }
      end
    end
  end


  # DELETE /users/:user_id/picture
  def destroy
    if @user.picture
      @user.picture.destroy
      respond_to do |format|
        format.xml { head :ok }
        format.html { flash[:notice] = I18n.t 'notices.picture_deleted'
                      redirect_to user_url(@user) }
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
