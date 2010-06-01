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

class SentMessagesController < ApplicationController

  before_filter :authenticate, :find_user

  # GET /sent_messages
  def index
    @messages = @user.sent_messages.find(:all,
                                         :conditions => "deleted = false",
                                         :order => "created_at DESC")
    respond_to do |format|
      format.xml { render }
    end
  end


  # GET /sent_messages/:id
  def show
    @message = Message.find_by_id(params[:id],
                                  :conditions => "deleted = false")
    if @message
      if @message.sender == @user
        respond_to do |format|
          format.xml { render }
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  # DELETE /sent_messages/:id
  def destroy
    @message = Message.find_by_id(params[:id],
                                  :conditions => "deleted = false")
    if @message
      if @message.sender == @user
        @message.deleted = true
        @message.save!
        head :ok
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
