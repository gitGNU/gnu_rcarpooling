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

class FulfilledDemandsController < ApplicationController

  before_filter :authenticate


  # GET /fulfilled_demands/id
  def show
    @fulfilled_demand = FulfilledDemand.find_by_id(params[:id])
    if @fulfilled_demand
      if @fulfilled_demand.suitor == User.find(params[:uid])
        respond_to do |format|
          format.xml { render :xml => @fulfilled_demand }
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  # DELETE /fulfilled_demands/id
  def destroy
    @fulfilled_demand = FulfilledDemand.find_by_id(params[:id])
    if @fulfilled_demand
      if @fulfilled_demand.suitor == User.find(params[:uid])
        unless @fulfilled_demand.chilled?
          # before destroy the fulfilled demand, process it :P
          processor = DemandProcessorFactory.build_processor
          processor.revoke_fulfilled_demand(@fulfilled_demand)
          processor.revoke_demand(@fulfilled_demand.demand)
          #
          @fulfilled_demand.demand.destroy
          @fulfilled_demand.destroy
          head :ok
        else
          head :method_not_allowed
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


end
