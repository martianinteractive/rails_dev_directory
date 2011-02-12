class EndorsementRequest < ActiveRecord::Base
  validates :message, :presence => true
  validate :recipient_count, :on => :create
  
  after_save :send_requests

  has_many :recipients, :class_name => 'EndorsementRequestRecipient'

  belongs_to :provider
  
  def recipient_addresses=(addresses = '')
    addresses.split(%r{,\s*}).each do |email|
      recipients.build(:email => email)
      recipient_addresses << email
    end
  end
  
  def recipient_addresses
    @recipient_addresses ||= Array.new
  end

  def send_requests
    recipients.each do |recipient|
      recipient.send_request
    end
  end

private

  def recipient_count
    errors.add(:recipients, I18n.t('endorsement_request.validations.no_recipients') ) if recipients.size == 0
    errors.add(:recipients, I18n.t('endorsement_request.validations.too_many_recipients') ) if recipients.size > 10
  end
end