class Admin::DashboardController < ApplicationController
  
  before_filter :admin_required
  
  layout 'admin'
  def show
    @providers = Provider.all
    @active_providers = Provider.active
    @inactive_providers = Provider.inactive
    @flagged_providers = Provider.flagged
    @rfps = Rfp.all
    @endorsements = Endorsement.all
  end
end
