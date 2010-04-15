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

class UserPicture < ActiveRecord::Base

  belongs_to :user


  belongs_to :db_file


  validates_presence_of :user


  has_attachment :content_type => :image,
                 :storage => :db_file,
                 :max_size => 100.kilobytes,
                 :resize_to => '96x96',
                 :processor => "ImageScience"


  validates_as_attachment

end
