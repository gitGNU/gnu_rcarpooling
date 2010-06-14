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

class UsedOfferingsController < ApplicationController


  before_filter :authenticate


  # GET /used_offerings/:id
  def show
    @used_offering = UsedOffering.find_by_id(params[:id])
    if @used_offering
      if @used_offering.offerer == User.find(params[:uid])
        respond_to do |format|
          format.html
          format.xml
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  # DELETE /used_offerings/:id
  def destroy
    @used_offering = UsedOffering.find_by_id(params[:id])
    if @used_offering
      if @used_offering.offerer == User.find(params[:uid])
        unless @used_offering.chilled?
          # before destroy the offering in use, process it :P
          @used_offering.lock!
          processor = OfferingProcessorFactory.build_processor
          processor.revoke_used_offering(@used_offering)
          processor.revoke_offering(@used_offering.offering)
          #
          @used_offering.offering.destroy
          @used_offering.destroy
          respond_to do |format|
            format.html do
              flash[:notice] = I18n.t 'notices.used_offering_deleted'
              redirect_to offerings_url
            end
            format.xml { head :ok }
          end
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
