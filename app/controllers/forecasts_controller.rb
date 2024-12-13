class ForecastsController < ApplicationController
  def new
    @forecast = Forecast.new
  end

  def show
    @zipcode = forecast_params[:zipcode]
    @forecast = Forecast.new(zipcode: @zipcode)

    unless @forecast.valid?
      redirect_to :forecasts_new, notice: "ZipCode is missing or not 5 digits"; return
    end

    status, result_json = @forecast.forecast_current(@zipcode)

    if status == 'Ok'
      @forecast_display = @forecast.extract_current(result_json)
    else
      redirect_to :forecasts_new, notice: "ZipCode not found"
    end
  end

  private

  def forecast_params
    params.require(:forecast).permit(:zipcode)
  end
end
