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

class LanguageTest < ActiveSupport::TestCase

  test "valid language" do
    language = Language.new(:name => "fr")
    assert language.valid?
    assert language.save
  end


  test "invalid without required fields" do
    language = Language.new
    assert !language.valid?
    assert language.errors.invalid?(:name)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        language.errors.on(:name)
  end


  test "name must be unique" do
    language = Language.new(:name => "ru")
    assert language.save
    another_language = Language.new(:name => "ru")
    assert !another_language.valid?
    assert another_language.errors.invalid?(:name)
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
        another_language.errors.on(:name)
  end


end
