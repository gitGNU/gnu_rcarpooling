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

class MessagesController < ApplicationController

  before_filter :authenticate, :find_user


  # POST /messages
  def create
    @message = Message.new
    @message.sender = @user
    if params[:message]
      m = params[:message]
      @message.subject = m[:subject]
      @message.content = m[:content]
      if m[:recipients_ids_string]
        m[:recipients_ids_string].split(',').each do |r|
          r_id = (r =~ /\<(\d+)\>/) && $1 || r
          recipient = User.find_by_id(r_id)
          @message.forwarded_messages << ForwardedMessage.new(
            :message => @message, :recipient => recipient)
        end
      end
    end
    if @message.save
      respond_to do |format|
        format.xml do
          render :template => 'sent_messages/show', :status => :created,
              :location => sent_message_url(@message)
        end
        format.html do
          flash[:notice] = I18n.t 'notices.message_sent'
          redirect_to sent_messages_url
        end
      end
    else
      respond_to do |format|
        format.xml do
          render :xml => @message.errors, :status => :unprocessable_entity
        end
        format.html { render :action => 'new' }
      end
    end
  end


  # GET /messages/new
  def new
    @message = Message.new
    @message.recipients_ids_string = params[:recipients]
  end


  private

  def find_user
    @user = User.find(params[:uid])
  end

end
