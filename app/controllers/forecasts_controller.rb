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

    # status, result_json = @forecast.forecast_current(@zipcode)
    
    @is_cached = is_cached(@zipcode) # used to display from cache

    # this code will return that cache value, or requery and cache it
    status, result_json = @forecast.cached_forecast(@zipcode)

    if status == 'Ok'
      @forecast_display = @forecast.extract_current(result_json)
      # a hash with 3 components; add min_temp_f, max_temp_f, then forecast, 5 day
      # This is what we want to cache, actually, result from 2nd query,  too
    else
      redirect_to :forecasts_new, notice: "ZipCode not found"
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
