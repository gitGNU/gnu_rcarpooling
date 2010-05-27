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

class ForwardedMessage < ActiveRecord::Base

  belongs_to :message

  belongs_to :recipient,
      :class_name => 'User',
      :foreign_key => 'recipient_id'


  validates_presence_of :message, :recipient

  validate :recipient_must_be_distinct_from_sender


  def sender
    message && message.sender
  end


  def subject
    message && message.subject
  end


  def content
    message && message.content
  end


  def seen?
    seen
  end


  private

  def recipient_must_be_distinct_from_sender
    if sender and recipient and sender == recipient
      errors.add(:recipient, I18n.t('activerecord.errors.messages.' +
          'forwarded_message.recipient_must_be_distinct_from_sender'))
    end
  end

end
