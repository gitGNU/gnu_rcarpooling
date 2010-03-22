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

  before_filter :authenticate


  # GET /demands/id
  def show
    @demand = Demand.find_by_id(params[:id])
    if @demand
      if @demand.suitor == User.find(params[:uid])
        unless @demand.fulfilled?
          respond_to do |format|
            format.xml { render :xml => @demand }
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
        format.xml { render :xml => @demand, :location => @demand,
                     :status => :created }
      end
    else
      respond_to do |format|
        format.xml { render :xml => @demand.errors,
                     :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /demands/id
  def destroy
    @demand = Demand.find_by_id(params[:id])
    if @demand
      if @demand.suitor == User.find(params[:uid])
        unless @demand.fulfilled?
          processor = DemandProcessorFactory.build_processor
          processor.revoke_demand(@demand)
          @demand.destroy
          head :ok
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
