class Admin::BasesController < ApplicationController
  def login_check
    if session[:user_id].blank?
      redirect_to '/'
    end
  end
end
