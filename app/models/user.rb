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

class User < ActiveRecord::Base


  has_many :demands,
      :foreign_key => "suitor_id",
      :class_name => "Demand"


  has_many :offerings,
      :foreign_key => "offerer_id",
      :class_name => "Offering"


  # black lists handling :)

  has_many :black_list_drivers_entries


  has_many :drivers_in_black_list,
      :through => :black_list_drivers_entries,
      :source => :driver


  has_many :black_list_passengers_entries


  has_many :passengers_in_black_list,
      :through => :black_list_passengers_entries,
      :source => :passenger

  # end of black lists handling :P


  belongs_to :language


  validates_presence_of :first_name, :last_name, :email, :nick_name,
      :language


  validates_uniqueness_of :nick_name, :email


  validates_numericality_of :max_foot_length, :only_integer => true,
      :greater_than_or_equal_to => 0


  validates_inclusion_of :sex, :in => %w{M F},
      :message => I18n.t('activerecord.errors.messages.user.sex_inclusion')


  def self.authenticate(nick_name, password)
    user = User.find_by_nick_name_and_password(nick_name, password)
    if user
      user.id
    else
      false
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

end
