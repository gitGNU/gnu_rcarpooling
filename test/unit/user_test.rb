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

class UserTest < ActiveSupport::TestCase

  test "invalid without required fields" do
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:first_name)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        user.errors.on(:first_name)
    assert user.errors.invalid?(:last_name)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        user.errors.on(:last_name)
    assert user.errors.invalid?(:nick_name)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        user.errors.on(:nick_name)
    assert user.errors.invalid?(:email)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        user.errors.on(:email)
    assert user.errors.invalid?(:language)
    assert_equal I18n.translate('activerecord.errors.messages.blank'),
        user.errors.on(:language)
    assert user.errors.invalid?(:sex)
    assert_equal I18n.t('activerecord.errors.messages.user.sex_inclusion'),
        user.errors.on(:sex)
  end


  test "valid user" do
    user = User.new :first_name => "Uncle", :last_name => "Scrooge",
        :nick_name => "us", :email => "uncle.scrooge@foo.bar",
        :password => "uncle", :language => languages(:en), :sex => "M"
    assert user.valid?
    assert user.save
  end


  test "sex must be M or F" do
    user = User.new(:sex => "invalid")
    assert !user.valid?
    assert user.errors.invalid?(:sex)
    assert_equal I18n.t('activerecord.errors.messages.user.sex_inclusion'),
        user.errors.on(:sex)
  end


  test "nick_name must be unique" do
    user = User.new
    user.nick_name = users(:donald_duck).nick_name
    assert !user.valid?
    assert user.errors.invalid?(:nick_name)
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
        user.errors.on(:nick_name)
  end


  test "email must be unique" do
    user = User.new
    user.email = users(:donald_duck).email
    assert !user.valid?
    assert user.errors.invalid?(:email)
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
        user.errors.on(:email)
  end


  test "static method authenticate" do
    assert !User.authenticate("blablabla", "bliblibli")
    assert User.authenticate(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
    assert !User.authenticate(users(:donald_duck).nick_name,
                              users(:mickey_mouse).password)
    assert_equal users(:donald_duck).id,
        User.authenticate(users(:donald_duck).nick_name,
                             users(:donald_duck).password)
  end


  test "black list of drivers" do
    donald_duck = users(:donald_duck)
    mickey_mouse = users(:mickey_mouse)
    # donald duck doesn't want mickey mouse as driver
    donald_duck.drivers_in_black_list << mickey_mouse
    donald_duck.reload; mickey_mouse.reload
    #
    assert donald_duck.valid?
    assert donald_duck.drivers_in_black_list.include?(mickey_mouse)
  end


  test "black list of passengers" do
    donald_duck = users(:donald_duck)
    mickey_mouse = users(:mickey_mouse)
    # mickey mouse doesn't want donald duck as passenger
    mickey_mouse.passengers_in_black_list << donald_duck
    donald_duck.reload; mickey_mouse.reload
    #
    assert mickey_mouse.valid?
    assert mickey_mouse.passengers_in_black_list.include?(donald_duck)
  end


  test "nice email address" do
    user = users(:donald_duck)
    expected_address = "#{user.first_name} #{user.last_name} " +
        "<#{user.email}>"
    assert_equal expected_address, user.nice_email_address
  end


  test "name" do
    user = users(:donald_duck)
    expected_name = "#{user.first_name} #{user.last_name}"
    assert_equal expected_name, user.name
  end


  test "qualification in English" do
    user = User.new(:language => languages(:en))
    # qualification without sex
    assert_equal "Mr./Mrs.", user.qualification
    # qualification if male
    user.sex = "M"
    assert_equal "Mr.", user.qualification
    # qualification if female
    user.sex = "F"
    assert_equal "Mrs./Miss", user.qualification
  end


  test "qualification in Italian" do
    user = User.new(:language => languages(:it))
    # qualification without sex
    assert_equal "Sig./Sig.a", user.qualification
    # qualification if male
    user.sex = "M"
    assert_equal "Sig.", user.qualification
    # qualification if female
    user.sex = "F"
    assert_equal "Sig.a/Sig.na", user.qualification
  end


  test "max foot length must be greater than or equal to 0" do
    user = User.new(:max_foot_length => -1)
    assert !user.valid?
    assert user.errors.invalid?(:max_foot_length)
    assert_equal I18n.t(
      'activerecord.errors.messages.greater_than_or_equal_to',
      :count => 0), user.errors.on(:max_foot_length)
  end


end
