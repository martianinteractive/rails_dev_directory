class Endorsement < ActiveRecord::Base
  include AASM
  
  validates :name, :year_hired, :position, :company, :email, :url,:endorsement, :endorsement_request_recipient_id, :presence => true
  validate :endorser_email_matches_email_recipient, :on => :create
  
  aasm_initial_state :new
  
  aasm_state :new
  aasm_state :approved
  aasm_state :rejected
  aasm_event :approve do
    transitions :to => :approved, :from => [:new, :rejected, :approved]
  end
  aasm_event :reject do
    transitions :to => :rejected, :from => [:new, :rejected, :approved]
  end
  
  attr_protected :provider_id, :aasm_state
  
  audit
  url_field :url
  format_dates :timestamps
  
  belongs_to :provider
  belongs_to :endorsement_request_recipient
  
  after_save :activate_provider
  after_save :update_provider_counter_cache
  after_create :deliver_notification
  after_destroy :update_provider_counter_cache
  
  scope :recent, :order => "created_at desc", :limit => 3
  scope :approved, :conditions => {:aasm_state => 'approved'}

  def activate_provider
    provider.check_endorsements_and_activate if provider and provider.status == 'inactive'
  end
  
  def update_provider_counter_cache
    self.provider.update_attribute(:endorsements_count, provider.endorsements.approved.count) if provider
  end
  
  def state
    aasm_state
  end
  
private
  def endorser_email_matches_email_recipient
    mail = Mail::Address.new(endorsement_request_recipient.email)
    parsed_email = mail.address rescue ''
    if parsed_email != self.email
      errors.add(:email, I18n.t('endorsement.validations.use_the_recipient_email'))
    end
  end

  def deliver_notification
    Notification.endorsement_notification(self).deliver if provider and provider.email
  end
end