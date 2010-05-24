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

class NotificationsController < ApplicationController

  before_filter :authenticate, :find_user


  def index
    @notifications = @user.notifications.paginate :page => params[:page],
        :per_page => 4
    render :update do |page|
      page.replace "notifications", :partial => "notifications",
          :object => @notifications
    end
  end


  def show
    n = Notification.find_by_id(params[:id])
    @notification =  @user.notifications.include?(n) && n
    if @notification
      unless @notification.seen
        @notification.seen = true
        @notification.save!
      end
      render :update do |page|
        page.replace "notification_#{@notification.id}",
            :partial => "notification_opened", :object => @notification
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
      head :forbidden if @user.id != params[:uid]
    else
      head :not_found
    end
  end

end
