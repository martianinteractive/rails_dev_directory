class EndorsementRequestRecipient < ActiveRecord::Base
  validates :email, :presence => true
  validate :valid_email_address, :on => :create
  
  before_create :create_validation_token
  
  belongs_to :endorsement_request
  
  def send_request
    Notification.endorsement_request(endorsement_request, self).deliver
  end
  
  private
  
  def create_validation_token
    self.validation_token = Authlogic::Random.friendly_token
  end
  
  def valid_email_address
    parsed_address = Mail::Address.new(self.email)
    errors.add(:email, I18n.t('endorsement_request_recipient.validations.invalid_email') ) unless parsed_address.address =~ /^[^@]*@[^\.]*\..*$/
  end
  
end
