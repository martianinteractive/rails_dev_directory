class StatesController < ApplicationController
  def show
    @providers = Provider.from_state(params[:state])
  end
end
