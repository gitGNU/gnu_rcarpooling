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

class UserPictureTest < ActiveSupport::TestCase

  test "invalid without required fields" do
    up = UserPicture.new
    assert !up.valid?
    assert up.errors.invalid?(:user)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        up.errors.on(:user)
    assert up.errors.invalid?(:size)
    assert up.errors.invalid?(:content_type)
    assert up.errors.invalid?(:filename)
  end


  test "valid picture" do
    up = UserPicture.new(:size => 50, :content_type => "image/png",
                         :filename => "file name",
                         :user => users(:mickey_mouse))
    assert up.valid?
    assert up.save
  end

end
