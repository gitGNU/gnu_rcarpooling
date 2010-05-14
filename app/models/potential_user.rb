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

class PotentialUser < ActiveRecord::Base

  validates_presence_of :account_name


  validate :password_cannot_be_blank


  def password=(pwd)
    unless pwd.blank?
      self.salt = self.id.to_s + rand.to_s
      self.hashed_password = User.encrypted_password(pwd, self.salt)
    end
  end


  def self.authenticate(account_name, password)
    p_user = PotentialUser.find_by_account_name(account_name)
    if p_user
      pwd_expected = User.encrypted_password(password, p_user.salt)
      return p_user.id if pwd_expected == p_user.hashed_password
    end
    false
  end


  private


  def password_cannot_be_blank
    unless hashed_password and salt
      errors.add(:password, I18n.t('activerecord.errors.messages.blank'))
    end
  end

end
