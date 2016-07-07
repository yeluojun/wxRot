class Api::V1::BasesController < ApplicationController
  def login_check
    if session[:current_user].blank?
      render json: { code: 500, msg: '请登陆' }
    end
  end
end
