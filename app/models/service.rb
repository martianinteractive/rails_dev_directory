class Service < ActiveRecord::Base
  acts_as_list
  
  scope :checked, :conditions => {:checked => true}, :order => "position asc"
  scope :ordered, :order => "position asc"
  scope :ordered_not_checked, :order => "position asc", :conditions => {:checked => false}
end