class ForecastsController < ApplicationController
  def new
    @forecast = Forecast.new
  end

  def show
    @zipcode = forecast_params[:zipcode]
    @forecast = Forecast.new(zipcode: @zipcode)

    # Is the input param valid?
    unless @forecast.valid?
      redirect_to :forecasts_new, notice: "ZipCode is missing or not 5 digits"; return
    end

    status, result = @forecast.cached_forecast_result(@zipcode)
    if status == 'Cached'
      @is_cached = true
      @forecast_display = result
    elsif status == 'Api'
      @is_cached = false
      @forecast_display = result
    else
      notice = 'Zipcode not found'
      redirect_to :forecasts_new, notice: notice
    end
  end

  private

  def is_cached(zipcode)
    # This will be nil, once the cache has expired
    # Used to know if we have a cached value
    Rails.cache.read("wxzipcode#{zipcode}") # was fetch, check
  end

  def forecast_params
    params.require(:forecast).permit(:zipcode)
  end
end
