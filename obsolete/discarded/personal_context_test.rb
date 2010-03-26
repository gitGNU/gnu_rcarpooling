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
require 'xml'
require 'libxslt'



class PersonalContextTest < ActionController::IntegrationTest
  fixtures :users, :languages

  test "user data transformation" do
    user = users(:donald_duck)
    user.drivers_in_black_list.clear
    user.passengers_in_black_list.clear
    user.passengers_in_black_list << users(:mickey_mouse)
    user.drivers_in_black_list << users(:mickey_mouse)
    user.save!
    #
    # obtaining user xml representation
    auth_field = encode_authorization_value(user.nick_name,
                                            user.password)
    get user_url(user), nil, "HTTP_AUTHORIZATION" => auth_field
    assert_response :success
    user_xml = XML::Document.string(response.body)
    # obtaining xslt
    get "/personal/transform/user.xsl"
    assert_response :success
    xslt_xml_doc = XML::Document.string(response.body)
    xslt_transform = LibXSLT::XSLT::Stylesheet.new(xslt_xml_doc)
    # make the transformation
    result = xslt_transform.apply(user_xml)
    #
    # testing the result
    bl_divs = result.find("//div[@class='user-black-list']")
    assert_equal 2, bl_divs.size
    bl_divs.each do |div|
      assert_equal 1, div.find("descendant::tr").size
    end
  end

end
