class Admin::BasesController < ApplicationController
  layout 'admin'
  def login_check
    if session[:user_id].blank?
      redirect_to '/'
    end
  end
end
