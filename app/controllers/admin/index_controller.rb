class Admin::IndexController < Admin::BasesController
  before_action :login_check
  def index
    redirect_to '/admin/weixins'
  end
end
