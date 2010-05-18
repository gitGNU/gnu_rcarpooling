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

require 'digest/sha1'

class User < ActiveRecord::Base


  has_many :demands,
      :foreign_key => "suitor_id",
      :class_name => "Demand",
      :dependent => :nullify


  has_many :offerings,
      :foreign_key => "offerer_id",
      :class_name => "Offering",
      :dependent => :nullify


  # black lists handling :)

  has_many :black_list_drivers_entries,
      :dependent => :destroy


  has_many :drivers_in_black_list,
      :through => :black_list_drivers_entries,
      :source => :driver


  has_many :black_list_passengers_entries,
      :dependent => :destroy


  has_many :passengers_in_black_list,
      :through => :black_list_passengers_entries,
      :source => :passenger

  # end of black lists handling :P

  # the picture image
  has_one :picture,
      :foreign_key => "user_id",
      :class_name => "UserPicture",
      :dependent => :destroy


  has_many :notifications,
      :foreign_key => 'recipient_id',
      :dependent => :destroy do
    def not_seen
      find :all, :conditions => ['seen = false']
    end
  end


  belongs_to :language


  validates_presence_of :first_name, :last_name, :email, :nick_name,
      :language


  validates_uniqueness_of :nick_name, :email


  validates_numericality_of :max_foot_length, :only_integer => true,
      :greater_than_or_equal_to => 0


  validates_inclusion_of :sex, :in => %w{M F},
      :message => I18n.t('activerecord.errors.messages.user.sex_inclusion')


  validate :password_cannot_be_blank


  before_save do |user|
    user.first_name = user.first_name.humanize
    user.last_name = user.last_name.humanize
  end


  before_validation do |user|
    if user.telephone_number
      user.telephone_number.strip!
      user.telephone_number = nil if user.telephone_number.empty?
    end
    if user.vehicle_registration_plate
      user.vehicle_registration_plate.strip!
      if user.vehicle_registration_plate.empty?
        user.vehicle_registration_plate = nil
      end
    end
  end


  def self.authenticate(nick_name, password)
    user = User.find_by_nick_name(nick_name)
    if user
      pwd_expected = encrypted_password(password, user.salt)
      return user.id if pwd_expected == user.hashed_password
    end
    false
  end


  def password=(pwd)
    unless pwd.blank?
      self.salt = self.id.to_s + rand.to_s
      self.hashed_password = User.encrypted_password(pwd, self.salt)
    end
  end


  def nice_email_address
    "#{first_name} #{last_name} <#{email}>"
  end


  def name
    "#{first_name} #{last_name}"
  end


  def qualification
    if lang == "en"
      if male?
        "Mr."
      elsif female?
        "Mrs./Miss"
      else
        "Mr./Mrs."
      end
    elsif lang == "it"
      if male?
        "Sig."
      elsif female?
        "Sig.a/Sig.na"
      else
        "Sig./Sig.a"
      end
    end
  end


  def qualified_name
    qualification + " " + name
  end


  def lang
    language.name
  end


  def male?
    "M" == sex
  end


  def female?
    "F" == sex
  end


  def has_picture?
    picture && true
  end


  def shows_telephone_number?
    telephone_number && true
  end


  def shows_vehicle_registration_plate?
    vehicle_registration_plate && true
  end


  def shows_email?
    true
  end


  def shows_picture?
    has_picture?
  end


  def notifications_not_seen
    notifications.not_seen
  end


  def self.encrypted_password(password, salt)
    Digest::SHA1.hexdigest(password + salt)
  end


  private


  def password_cannot_be_blank
    unless hashed_password and salt
      errors.add(:password, I18n.t('activerecord.errors.messages.blank'))
    end
  end

end
