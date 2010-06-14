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

class IncomingMessagesController < ApplicationController

  before_filter :authenticate, :find_user

  # GET /incoming_messages
  def index
    @incoming_messages = @user.incoming_messages.paginate(
        :per_page => 6, :page => params[:page])
    if request.xhr?
      render :update do |page|
        page.replace 'incoming_messages', :partial => 'incoming_messages',
            :object => @incoming_messages
      end
    else
      respond_to do |format|
        format.html
        format.xml { @incoming_messages = @user.incoming_messages }
      end
    end
  end


  # GET /incoming_messages/:id
  def show
    @incoming_message = ForwardedMessage.find_by_id(params[:id],
                                          :conditions => "deleted = false")
    if @incoming_message
      if @incoming_message.recipient == @user
        @incoming_message.seen = true
        @incoming_message.save!
        if request.xhr?
          render :update do |page|
            page.replace 'opened_message', :partial => 'opened_message',
                :object => @incoming_message
          end
        else
          respond_to do |format|
            format.xml
          end
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  # DELETE /incoming_messages/:id
  def destroy
    @incoming_message = ForwardedMessage.find_by_id(params[:id],
                                          :conditions => "deleted = false")
    if @incoming_message
      if @incoming_message.recipient == @user
        @incoming_message.deleted = true
        @incoming_message.save!
        if request.xhr?
          render :update do |page|
            page.remove "incoming_message_#{@incoming_message.id}"
          end
        else
          head :ok
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  private

  def find_user
    @user = User.find(params[:uid])
  end

end
