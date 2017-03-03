module Shoppe
  class DashboardController < Shoppe::ApplicationController
  	before_filter :login_required
    def home
      redirect_to :orders
    end
  end
end
