class Forecast < ApplicationRecord
  require 'httparty'

  validates :zipcode, length: {minimum: 5, maximum: 5}, numericality: { only_integer: true }, allow_blank: false

  API_KEY = '162cfc912bc544bba9b195514241212' # TBD put in secrets, for weatherapi.com

  CURRENT_URL = 'http://api.weatherapi.com/v1/current.json?'
  FORECAST_URL = 'http://api.weatherapi.com/v1/forecast.json?' 
  HISTORY_URL = 'http://api.weatherapi.com/v1/history.json?' 
   #key=162cfc912bc544bba9b195514241212&q=87507&dt=2024-12-12'

  def forecast_current(zipcode)
    url = "#{CURRENT_URL}key=#{API_KEY}&q=#{zipcode}"
    response = HTTParty.get(url)

    if response['error'].present?
      return ['Error', JSON.parse(response.body)]
    else
      return ['Ok', JSON.parse(response.body)]
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

  # def forecast_forecast(zipcode)
  #   url = "#{FORECAST_URL}key=#{API_KEY}&q=#{zipcode}&days=1"
  #   response = HTTParty.get(url)
  # end

  # def extract_forecast

  # end

  # def forecast_history(zipcode)
  #   #key=162cfc912bc544bba9b195514241212&q=87507&dt=2024-12-12'
  #   url = "#{FORECAST_URL}key=#{API_KEY}&q=#{zipcode}"
  #   response = HTTParty.get(url)
  # end

  # def extract_history

  # end
end
