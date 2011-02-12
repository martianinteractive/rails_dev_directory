require 'exportable'
class Provider < ActiveRecord::Base
  include AASM
  
  validates :company_name, :city, :email, :company_url, :presence => true
  validates :slug, :uniqueness => true
  validates :terms_of_service, :acceptance => true
  validates :marketing_description, :length => {:maximum => 300, :allow_nil => true}
  validate :name_is_not_a_reserved_country_name
  
  audit
  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "64x64>" }
  format_dates :timestamps
  
  aasm_initial_state :inactive

  aasm_state :active
  aasm_state :flagged
  aasm_state :inactive
  aasm_event :activate do
    transitions :to => :active, :from => [:inactive]
  end
  
  url_field :company_url
  
  attr_protected :aasm_state, :slug, :user_id, :endorsements_count
  
  has_many :users, :dependent => :destroy
  has_many :requests, :dependent => :destroy, :order => 'created_at desc'
  has_many :rfps, :through => :requests
  has_many :endorsements, :order => "sort_order asc"
  has_many :endorsement_requests
  has_many :portfolio_items, :order => "year_completed desc"
  
  has_many :provided_services, :dependent => :destroy
  has_many :services, :through => :provided_services
  
  belongs_to :user
  
  accepts_nested_attributes_for :users
  
  before_validation :save_slug, :on => :create
  before_validation :filter_carraige_returns
  before_create :set_first_user_provider
  after_create :set_first_user_as_owner
  after_create :send_owner_welcome
  after_create :set_default_services
  
  scope :active, :conditions => {:aasm_state => 'active'}, :order => :company_name
  scope :inactive, :conditions => {:aasm_state => 'inactive'}, :order => :company_name
  scope :flagged, :conditions => {:aasm_state => 'flagged'}, :order => :company_name
  scope :all_by_company_name, :order => :company_name
  scope :by_country, :group => :country, :order => :country, :select => :country, :conditions => "country != ''"
  scope :by_state, :conditions => "state_province != 'NA' and state_province != ''", :group => :state_province, :order => :state_province, :select => :state_province
  scope :us_based, :conditions => {:country => 'US'}
  scope :all_by_location, :order => "country, state_province", :conditions => "country != ''"
  scope :from_country, lambda { |country| {:conditions => {:country => country.to_s}}}
  scope :from_state, lambda { |state| {:conditions => {:state_province => state.to_s}}}
  
  def self.find(*args)
    if args.not.many? and args.first.kind_of?(String) and args.first.not.match(/^\d*$/)
      find_by_slug(args)
    else
      super(*args)
    end
  end
  
  def self.search(params)
    conditions = ["aasm_state != 'flagged'"]
    if params[:budget].not.blank?
      conditions[0] << " and min_budget <= ?"
      conditions << params[:budget].gsub(/[^0-9\.]/, '').to_i
    end

    joins = nil
    group = nil

    if params[:service_ids].not.blank? and params[:service_ids].is_a?(Array)
      params[:service_ids].each do |id|
        conditions[0] << " and EXISTS (select * from provided_services where service_id = ? and provider_id = providers.id)"
        conditions << id.to_i
      end
    end
    
    if params[:location].not.blank?
      if params[:location][0,3] == 'US-'
        conditions[0] << " and state_province = ?"
        conditions << params[:location].gsub('US-', '')
      else
        conditions[0] << " and country = ?"
        conditions << params[:location]
      end
    end
    
    if params[:countries].not.blank? and params[:countries].is_a?(Array)
      conditions[0] << " and country IN (?)"
      conditions << params[:countries]
    end
    
    if params[:states].not.blank? and params[:states].is_a?(Array)
      if params[:countries].not.blank? and params[:countries].is_a?(Array)
        conditions[0] << " and if(country = 'US', state_province IN (?), ?)"
        conditions << params[:states]
        conditions << true
      else
        conditions[0] << " and state_province IN (?)"
        conditions << params[:states]
      end
    end

    all(:joins => joins, :group => group, :conditions => conditions, :order => "aasm_state asc, if(endorsements_count >= 3,endorsements_count,0) desc, RAND()", :limit => 10)
  end
  
  def self.locations_for_select
    out = []
    by_country.each do |provider|
      out << [I18n.t("countries.#{provider.country}"), provider.country]
    end
    out
  end

  def to_param
    slug
  end
  
  def self.options_for_company_size
    [["2-10", 2], ["11-30", 11], ["31-100", 31], ["100+", 100]]
  end
  
  def self.states
    aasm_states.collect { |s| s.name.to_s }
  end
  
  def active?
    aasm_state == 'active'
  end
  
  def address
    [
      street_address,
      city,
      State.by_code(state_province),
      postal_code,
      country.blank? ? nil : I18n.t('countries')[country.to_sym]
        ].reject { |part| part.blank?}
  end
  
  def private_address
    [ 
      city,
      State.by_code(state_province),
      country.blank? ? nil : I18n.t('countries')[country.to_sym]
        ].reject { |part| part.blank?}
  end
  
  def status
    aasm_state
  end
  
  def slugged_company_name
    company_name.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s/,'-') if company_name
  end
  
  def users_for_select
    users.collect { |u| [u.name, u.id] }
  end
  
  def hourly_rate_formatted
    return nil if hourly_rate.nil?
    "%.2f" % hourly_rate
  end
  
  def min_budget_formatted
    return nil if min_budget.nil?
    "%.2f" % min_budget
  end

  def check_endorsements_and_activate
    activate! if endorsements.approved.size >= 3
  end

  def has_enough_portfolio_items?
    portfolio_items.size >= 3
  end
  
  def can_edit?(user)
    users.include?(user)
  end
  
private
  def save_slug
    self.slug = slugged_company_name
  end
  
  def set_first_user_as_owner
    update_attribute(:user, users.first) if users.first
  end
  
  def set_first_user_provider
    users.first.provider = self if users.first
  end
  
  def send_owner_welcome
    Notification.provider_welcome(user).deliver if user
  end
  
  def owner_name
    user.name if user
  end
  
  def owner_email
    user.email if user
  end
  
  def set_default_services
    Service.checked.each do |service|
      services << service
    end
  end
  
  def filter_carraige_returns
    return if marketing_description.blank?
    self.marketing_description = marketing_description.gsub("\r\n", "\n")
  end
  
  def name_is_not_a_reserved_country_name
    if Country.slugs.include?(slugged_company_name) or State.slugs.include?(slugged_company_name)
      errors.add(:company_name, I18n.t('provider.validations.reserved_name'))
    end
  end
end