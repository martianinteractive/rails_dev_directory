class ContactMessagesController < ApplicationController
  
  def new
    @contact_message = ContactMessage.new
  end

  def create
    @contact_message = ContactMessage.new(params[:contact_message])

    if @contact_message.save
      flash[:notice] = 'Your message has been received.'
      redirect_to(root_path)
    else
      render :action => "new"
    end
  end

end
