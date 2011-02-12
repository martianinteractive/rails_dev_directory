class Audit < ActiveRecord::Base
  belongs_to(:auditable, :polymorphic => true)
  belongs_to :user
  
  scope :created, :conditions => {:action => 'create'}
  scope :updated, :conditions => {:action => 'update'}
  scope :destroyed, :conditions => {:action => 'destroy'}
  
  scope :by_object, lambda { |auditable_type| { :conditions => ['auditable_type = ?', auditable_type] } }
end