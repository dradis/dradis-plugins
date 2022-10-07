module Dradis::Plugins
  class EnginesController < AuthenticatedController
    before_action :set_settings

    def enable
      if @settings.engine_enable
        redirect_to request.referer, alert: "#{engine_name} is already enabled."
      else
        @settings.toggle_engine(true)
        redirect_to request.referer, notice: "#{engine_name} successfully enabled!"
      end
    end

    def disable
      unless @settings.engine_enable
        redirect_to request.referer, alert: "#{engine_name} is already disabled."
      else
        @settings.toggle_engine(false)
        redirect_to request.referer, notice: "#{engine_name} successfully disabled!"
      end
    end

    private

    def set_settings
      @settings = Dradis::Plugins::Settings.new(params[:engine])
    end

    def engine_name
      params[:engine].capitalize
    end
  end
end
