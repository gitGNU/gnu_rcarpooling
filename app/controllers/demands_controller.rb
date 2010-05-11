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

class DemandsController < ApplicationController

  before_filter :authenticate, :except => "new"


  # GET /demands
  def index
    @user = User.find(params[:uid])
    respond_to do |format|
      format.xml {
        @demands = @user.demands.find :all, :order => 'created_at DESC'
      }
      format.html {
        @demands = @user.demands.paginate :page => params[:page],
          :order => 'created_at DESC', :per_page => 4
      }
    end
  end


  # GET /demands/new
  def new
    @demand = Demand.new(:expiry_time => 7.minutes.from_now,
                         :earliest_departure_time => 12.minutes.from_now,
                         :latest_arrival_time => 3.hour.from_now)
    @places = Place.find :all
  end


  # GET /demands/:id
  def show
    @demand = Demand.find_by_id(params[:id])
    if @demand
      if @demand.suitor == User.find(params[:uid])
        unless @demand.fulfilled?
          respond_to do |format|
            format.xml
            format.html
          end
        else
          redirect_to(fulfilled_demand_url(@demand.fulfilled_demand),
                      :status => :temporary_redirect)
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  # POST /demands
  def create
    @demand = Demand.new(params[:demand])
    @demand.suitor = User.find(params[:uid])
    if @demand.save
      # now process the demand just saved :)
      processor = DemandProcessorFactory.build_processor
      processor.process_incoming_demand(@demand)
      #
      respond_to do |format|
        format.xml { render :action => "show", :location => @demand,
                     :status => :created }
        format.html { flash[:notice] = I18n.t 'notices.demand_created'
                      redirect_to demand_url(@demand) }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @demand.errors,
                     :status => :unprocessable_entity }
        format.html { @places = Place.find :all
                      render :action => "new" }
      end
    end
  end


  # DELETE /demands/:id
  def destroy
    @demand = Demand.find_by_id(params[:id])
    if @demand
      if @demand.suitor == User.find(params[:uid])
        unless @demand.fulfilled?
          if @demand.deletable?
            processor = DemandProcessorFactory.build_processor
            processor.revoke_demand(@demand)
            @demand.destroy
            respond_to do |format|
              format.xml { head :ok }
              format.html { flash[:notice] =
                            I18n.t 'notices.demand_deleted'
                          redirect_to demands_url }
            end
          else
            head :method_not_allowed
          end
        else
          redirect_to(fulfilled_demand_url(@demand.fulfilled_demand),
                      :status => :temporary_redirect)
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end

end
