module ApplicationHelper
  
  def yes_or_no(status)
    return I18n.t('general.yes') if status
    return I18n.t('general.no')
  end
  
  def display_flash
    return content_tag(:div, flash[:notice], :class => 'notice') if flash[:notice]
    return content_tag(:div, flash[:error], :class => 'error') if flash[:error]
    return content_tag(:div, flash[:warning], :class => 'warning') if flash[:warning]
  end
  
end
