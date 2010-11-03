class Admin::NotificationEmailsController < ApplicationController
  
  resources_controller_for :notification_emails
  before_filter :admin_required
  layout 'bare'
  
  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfuly created a new notification email!"
        redirect_to admin_notification_emails_path
      else
        render :action => 'new'
      end
    end
  end
  
  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfuly edited the notification email!"
        redirect_to admin_notification_emails_path
      else
        render :action => 'edit'
      end
    end
  end
  
  def mark_to_send
    notification_email = find_resource
    notification_email.update_attributes({ :status => 1 })
    redirect_to :back
  end
  
  def mark_as_draft
    notification_email = find_resource
    notification_email.update_attributes({ :status => 0 })
    redirect_to :back
  end
  
end
