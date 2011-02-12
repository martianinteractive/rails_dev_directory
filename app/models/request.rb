class Request < ActiveRecord::Base
  belongs_to :provider
  belongs_to :rfp

  after_create :send_rfp_notification
  
  audit
  
  scope :recent, :order => "created_at DESC", :limit => 5
  
  def can_view?(user)
    provider.users.include?(user)
  end

private
  
  def send_rfp_notification
    Notification.rfp_notification(self).deliver if provider and provider.user
  end
end
