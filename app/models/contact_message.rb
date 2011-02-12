class ContactMessage < ActiveRecord::Base
  validates_presence_of :name, :email, :message
  validates_length_of :name, :within => 3..200
  validates_length_of :email, :within => 3..200
  validates_length_of :message, :within => 3..1000
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end
