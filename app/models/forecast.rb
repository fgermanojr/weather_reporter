class Forecast < ApplicationRecord
  require 'httparty' # could have used Net::HTTP directly, but some abstraction added

  validates :zipcode, length: {minimum: 5, maximum: 5}, numericality: { only_integer: true }, allow_blank: false

  CURRENT_URL = 'http://api.weatherapi.com/v1/current.json?' # not used
  FORECAST_URL = 'http://api.weatherapi.com/v1/forecast.json?' 
  HISTORY_URL = 'http://api.weatherapi.com/v1/history.json?' # not used

  def cache_forecast(zipcode)
    # make api call, cache needed ui result from api
    # calls forecast_forecast to make api call
    # then calls extract_current, extract_forecast, to return a current_hash with forecast added
    # key used wxzipcodeNNNNN
    # returns status, result_json (or err hash)
    # The expensive operation, the api call
    # it could return an error, don't cache that.
    current_hash = nil
    status, parsed_json = forecast_forecast(zipcode)
    if status == 'Ok'
      Rails.cache.fetch("wxzipcode#{zipcode}", expires_in: 1.minute) do # TBD *** change to 30.minutes
        current_hash = extract_current(parsed_json)
        forecast_array = extract_forecast(parsed_json)
        current_hash[:forecast] = forecast_array
        current_hash
      end
      return [status, current_hash]
    else
      return [status, parsed_json]
    end
  end

  def cached_forecast_result(zipcode)
    # returns cached result if in cache
    # otherwise api call
    # if good, cache it and return new value
    # otherwise return error without caching
    # return is [status, result], error returned in result
    cached_result = Rails.cache.read("wxzipcode#{zipcode}")
    if cached_result
      return ['Cached', cached_result]
    else
      # API call
      status, result = cache_forecast(zipcode)
      if status == 'Ok'
        return ['Api', result]
      else
        # we don't want to cache a error value
        # {"error"=>{"code"=>1006, "message"=>"No matching location found."}}
        # other api errors are possible, bad token, network error, ...
        message = result['error']['message']
        return ['Error', message]
      end
    end
  end

  def format_response(response)
    # we break out the error status, so success is easily recognized
    parsed_json = JSON.parse(response)
    # different apis will have different way of flagging errors
    if parsed_json['error'].present?
      return ['Error', parsed_json]
      #                looks like {"error"=>{"code"=>1006, "message"=>"No matching location found."}}
      # we are passing a api specific error detail up to caller, ok here, but think about other apis
    else
      return ['Ok', parsed_json]
    end
  end

  def extract_current(parsed_json)
    # pull only the fields needed, return as hash

    # { "location": {
    #     "name": "Santa Fe",
    #     "region": "New Mexico",
    #     "country": "USA",
    #     "lat": 35.6768,
    #     "lon": -105.958,
    #     "tz_id": "America/Denver",
    #     "localtime_epoch": 1734108121,
    #     "localtime": "2024-12-13 09:42"
    #   }, "current": {
    #     "last_updated_epoch": 1734107400,
    #     "last_updated": "2024-12-13 09:30",
    #     "temp_c": 1.1,
    #     "temp_f": 34.0, ...
    #   }
    # }
    location_name = parsed_json['location']['name']
    location_region = parsed_json['location']['region']
    current_temp_f = parsed_json['current']['temp_f']

    { location_name: location_name, location_region: location_region, current_temp_f: current_temp_f }
  end

  def forecast_forecast(zipcode)
    # TBD future,why is ENV['WEATHER_API_KEY'] failing? Should work.
    # Secrets set on local maching using VISUAL="code --wait" bin/rails credentials:edit
    # apis:
    #   weather_api_key: <AVALUE>
    api_key = Rails.application.credentials.apis[:weather_api_key]
    url = "#{FORECAST_URL}key=#{api_key}&q=#{zipcode}&days=5"
    response = HTTParty.get(url)

    format_response(response.body)
  end

  def extract_forecast(parsed_json)
    forecast_date_array = parsed_json['forecast']['forecastday']
    forecast_date_array.map do |forecast_day|
       { 
        date: forecast_day['date'],
        max_temp_f: forecast_day['day']['maxtemp_f'],
        min_temp_f: forecast_day['day']['mintemp_f'],
        condition: forecast_day['day']['condition']['text']
       }
    end
  end
end
