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
    if @user.id != params[:uid]
      if @user.shows_picture?
        pict = @user.picture
        send_data pict.current_data, :type => pict.content_type,
                  :disposition => 'inline', :filename => pict.filename
      else
        head :forbidden
      end
    else
      if @user.has_picture?
        pict = @user.picture
        send_data pict.current_data, :type => pict.content_type,
                  :disposition => 'inline', :filename => pict.filename
      else
        head :not_found
      end
    end
  end


  # GET /users/:user_id/edit
  def edit
    if @user.id != params[:uid]
      head :forbidden
    else
      render
    end
  end


  # PUT /users/:user_id/picture
  def update
    if @user.id != params[:uid]
      head :forbidden
    else
      @user.picture.destroy if @user.has_picture?
      @user.picture = UserPicture.new(params[:picture])
      @picture = @user.picture
      if @picture.save
        respond_to do |format|
          format.html do
            flash[:notice] = I18n.t 'notices.picture_uploaded'
            redirect_to user_url(@user)
          end
          format.xml { head :no_content }
        end
      else
        respond_to do |format|
          format.html { render :action => "edit" }
          format.xml do
            render :xml => @picture.errors,
                :status => :unprocessable_entity
          end
        end
      end
    end
  end


  # DELETE /users/:user_id/picture
  def destroy
    if @user.id != params[:uid]
      head :forbidden
    else
      if @user.has_picture?
        @user.picture.destroy
        respond_to do |format|
          format.html do
            flash[:notice] = I18n.t 'notices.picture_deleted'
            redirect_to user_url(@user)
          end
          format.xml { head :ok }
        end
      else
        head :not_found
      end
    end
  end


  private


  def find_user
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
    if !@user
      head :not_found
    end
  end


end
