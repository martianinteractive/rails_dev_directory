class PortfolioItem < ActiveRecord::Base
  validates :name, :url, :year_completed, :description, :presence => true
  validate :is_not_the_fourth_item, :on => :create
  
  can_has?
  url_field :url
  acts_as_textiled :description
  
  belongs_to :provider

private
  def is_not_the_fourth_item
    errors.add_to_base(I18n.t('portfolio_item.validations.too_many')) if provider.has_enough_portfolio_items?
  end
  
end
