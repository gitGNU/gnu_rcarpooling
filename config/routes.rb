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

ActionController::Routing::Routes.draw do |map|
  map.resources :offerings, :only => [:show, :create, :destroy, :new,
                                      :index]
  map.resources :used_offerings, :only => [:show, :destroy]
  map.resources :demands, :only => [:show, :create, :destroy, :new,
                                    :index]
  map.resources :fulfilled_demands, :only => [:show, :destroy]
  map.resources :places, :only => [:index, :show]
  map.resources :users, :only => [:show, :update, :create, :edit, :new],
      :collection => { :me => :get, :search => :get } do |user|
    user.resource :picture,
        :only => [:show, :edit, :update, :destroy]
    user.resources :unwelcome_passengers,
        :only => [:show, :create, :destroy, :index]
    user.resources :unwelcome_drivers,
        :only => [:show, :create, :destroy, :index]
  end
  #
  map.home '',
      :conditions => { :method => :get },
      :controller => "home",
      :action => "index"
  map.login_get '/login',
      :conditions => { :method => :get },
      :controller => "users",
      :action => "login"
  map.login '/login',
      :conditions => { :method => :post },
      :controller => "users",
      :action => "login"
  map.logout '/logout',
      :conditions => { :method => :post },
      :controller => "users",
      :action => "logout"
  map.connect '/authors',
      :conditions => { :method => :get },
      :controller => "home",
      :action => "authors"
  map.connect '/guide',
      :conditions => { :method => :get },
      :controller => "home",
      :action => "guide"
end
