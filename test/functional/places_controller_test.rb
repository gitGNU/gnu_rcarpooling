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

class PlacesControllerTest < ActionController::TestCase

  test "get all places" do
    get :index
    assert_response :success
    assert_not_nil assigns(:places)
  end


  test "get a particular place" do
    get :show, :id => places(:sede_di_via_ravasi).id
    assert_response :success
    assert_not_nil assigns(:place)
  end


  test "not found with wrong id" do
    get :show, :id => -1
    assert_response :not_found
  end


end