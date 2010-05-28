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

class Message < ActiveRecord::Base

  has_many :forwarded_messages,
      :validate => false # see validates_associated below

  has_many :recipients, :through => :forwarded_messages

  belongs_to :sender,
      :class_name => 'User',
      :foreign_key => 'sender_id'


  validates_presence_of :subject, :content, :sender

  validates_length_of :subject, :maximum => 100,
      :allow_nil => true

  validates_length_of :content, :maximum => 20000,
      :allow_nil => true

  validates_associated :forwarded_messages,
      :message => I18n.t('activerecord.errors.messages.message.' +
                         'forwarded_messages_invalid')

  validate :presence_of_fwd_messages


  def deleted?
    deleted
  end


  private

  def presence_of_fwd_messages
    unless forwarded_messages.length > 0
      errors.add(:forwarded_messages, I18n.t('activerecord.errors.messages.' +
                                          'message.forwarded_messages_empty'))
    end
  end

end
