class SessionsController < ApplicationController
  # 登陆
  def create
     @user = User.where(name: params[:name], password: params[:password]).first
     if @user.blank?
       render json: { code: 400, msg: '用户名或密码错误' }
     else
       session[:user_id] = @user.id
       self.current_user = @user
       render json: { code: 200, msg: '登陆成功' }
     end
  end

  # 登出
  def destroy
    session[:user_id] = nil
    self.current_user = nil
    render json: { code: 200, msg: '注销成功' }
  end

end
