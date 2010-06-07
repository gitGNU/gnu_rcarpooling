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
require 'digest/sha1'

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
    assert user.errors.invalid?(:password)
    assert_equal I18n.t('activerecord.errors.messages.blank'),
        user.errors.on(:password)
  end


  test "valid user" do
    user = User.new :first_name => "Uncle", :last_name => "Scrooge",
        :nick_name => "us", :email => "uncle.scrooge@foo.bar",
        :password => "uncle", :language => languages(:en), :sex => "M"
    # default value for messages email forwarding
    assert user.wants_message_by_email?
    # default value for public profile visibility
    assert_equal User::PUBLIC_VISIBILITY[:no_one],
        user.public_profile_visibility
    #
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


  test "public profile visibility must be one in PUBLIC VISIBILITY" do
    user = User.new(:public_profile_visibility => -1) # invalid value
    assert !user.valid?
    assert user.errors.invalid?(:public_profile_visibility)
    assert_equal I18n.t('activerecord.errors.messages.user.' +
                        'profile_visibility_inclusion',
                        :values => User.public_visibility_values),
                 user.errors.on(:public_profile_visibility)
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


  test "set password" do
    user = User.new
    #
    user.password = ""
    assert_nil user.hashed_password
    assert_nil user.salt
    #
    password = "this is a password"
    user.password = password
    assert_nil user.password # password is a field used only for tests
    assert_equal User.encrypted_password(password, user.salt),
        user.hashed_password
  end


  test "static method encrypt" do
    string1 = "foo"
    string2 = "bar"
    assert_equal Digest::SHA1.hexdigest(string1 + string2),
        User.encrypted_password(string1, string2)
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


  test "humanize first and last name" do
    user = User.new :first_name => "uncle", :last_name => "scRooge",
        :nick_name => "us", :email => "uncle.scrooge@foo.bar",
        :password => "uncle", :language => languages(:en), :sex => "M"
    assert user.save
    assert_equal "Uncle", user.first_name
    assert_equal "Scrooge", user.last_name
  end


  test "telephone empty becomes nil before validation" do
    user = User.new :telephone_number => ""
    user.valid?
    assert_nil user.telephone_number
    # but...
    user.telephone_number = "123"
    user.valid?
    assert_equal "123", user.telephone_number
  end


  test "license plate empty becomes nil before validation" do
    user = User.new :vehicle_registration_plate => ""
    user.valid?
    assert_nil user.vehicle_registration_plate
    # but...
    user.vehicle_registration_plate = "abc"
    user.valid?
    assert_equal "abc", user.vehicle_registration_plate
  end


  test "car details empty becomes nil before validation" do
    user = User.new :car_details => ""
    user.valid?
    assert_nil user.car_details
    # but...
    user.car_details = "I have got a red car"
    user.valid?
    assert_equal "I have got a red car", user.car_details
  end


  test "telephone and vehicle plate full of spaces" do
    user = User.new :vehicle_registration_plate => "   ",
        :telephone_number => "  "
    user.valid?
    assert_nil user.vehicle_registration_plate
    assert_nil user.telephone_number
  end


  test "car details full of spaces" do
    user = User.new :car_details => "     "
    user.valid?
    assert_nil user.car_details
  end


  test "car details max length" do
    user = User.new
    string = "aaaaaaaaaa"
    51.times { string += "aaaaaaaaaa" }
    user.car_details = string
    assert !user.valid?
    assert user.errors.invalid?(:car_details)
    assert_equal I18n.t('activerecord.errors.messages.too_long',
                        :count => User::CAR_DETAILS_MAX_LENGTH),
                        user.errors.on(:car_details)
  end


  test "shows telephone number" do
    user = User.new
    assert ! user.shows_telephone_number?
    user.telephone_number = "123"
    assert user.shows_telephone_number?
  end


  test "shows vehicle registration plate" do
    user = User.new
    assert ! user.shows_vehicle_registration_plate?
    user.vehicle_registration_plate = "abc123"
    assert user.shows_vehicle_registration_plate?
  end


  test "shows email" do
    user = User.new
    assert user.shows_email?
  end


  test "shows picture" do
    user = User.new
    assert ! user.shows_picture?
    user.picture = UserPicture.new
    assert user.shows_picture?
  end


  test "shows car details" do
    user = User.new
    assert ! user.shows_car_details?
    user.car_details = "foo bar"
    assert user.shows_car_details?
  end


  test "notifications" do
    user = users(:donald_duck)
    # donald duck has 3 notifications, 2 not seen
    notifications = user.notifications
    assert_equal 3, notifications.size
    assert notifications.include?(notifications(:dd1))
    assert notifications.include?(notifications(:dd2))
    assert notifications.include?(notifications(:dd3))
    #
    notifications = user.notifications_not_seen
    assert_equal 2, notifications.size
    assert notifications.include?(notifications(:dd1))
    assert notifications.include?(notifications(:dd2))
  end


  test "constant value for no-one public profile visibility" do
    assert_equal 0, User::PUBLIC_VISIBILITY[:no_one]
  end


  test "fulfilled demands method" do
    user = users(:donald_duck)
    expected = user.demands.map do |d|
      d.fulfilled_demand if d.fulfilled?
    end
    expected.reject! { |item| item.nil? }
    assert_equal expected, user.fulfilled_demands
  end


  test "used offerings method" do
    user = users(:donald_duck)
    expected = user.offerings.map do |o|
      o.used_offering if o.in_use?
    end
    expected.reject! { |item| item.nil? }
    assert_equal expected, user.used_offerings
  end


  test "method knows" do
    assert users(:donald_duck).knows?(users(:mickey_mouse))
    assert users(:mickey_mouse).knows?(users(:donald_duck))
    assert !users(:donald_duck).knows?(users(:donald_duck))
    assert !users(:user_N).knows?(users(:mickey_mouse))
  end

end
