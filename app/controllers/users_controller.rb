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

  before_filter :authenticate

  # GET /users/:id
  def show
    @user = User.find_by_id(params[:id])
    if @user
      if params[:uid] == @user.id
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


  # GET /users/me
  def me
    @user = User.find(params[:uid])
    redirect_to @user, :status => :temporary_redirect
  end

end
