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

require 'test_helper'

class AdsControllerTest < ActionController::TestCase

  test "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ads)
    ads = assigns(:ads)
    assert_equal Ad.find(:all), ads
    # testing response content
    assert_select "ads:root[href=#{ads_url}]" do
      ads.each do |ad|
        assert_select "ad[id=#{ad.id}]" do
          assert_select "subject", ad.subject
          assert_select "content", ad.content
          assert_select "created_at", ad.created_at.xmlschema
        end
      end
    end
  end


  test "get index by xhr" do
    xhr(:get, :index)
    assert_response :success
    assert_equal 'text/javascript', @response.content_type
    assert_not_nil assigns(:ads)
  end

end
