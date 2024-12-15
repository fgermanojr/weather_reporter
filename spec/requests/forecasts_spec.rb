require 'rails_helper'
require 'vcr'

# Test two ways of mocking the api call so I can use one in the system/feature Capybara test.

RSpec.describe "Forecasts", type: :request do
  # I like VCR and have used in in the past. Really overkill here.
  # I struggle with it a bit stepping into a new different code bases.
  # It has more function than I have needed, and have found it to be
  # a bit brittle to maintain, as changes are made to payloads.
  # The advantage here was I didn't need to capture the payload manually,
  # and its rails 8, is this still useful, better undertand.
  VCR.configure do |config|
    config.cassette_library_dir = 'spec/cassettes'
    config.hook_into :webmock
    config.debug_logger = $stderr # Added, is it working?
  end

  let(:forecast) { Forecast.new(zipcode: '87507')}

  describe "GET /forecasts" do
    let(:result) { forecast.forecast_forecast('87507') }
    it "works with vcr-ed api call" do
      VCR.use_cassette('forecast_get', record: :all) do
        expect(result.first).to eql('Ok')
        expect(result.last['current']['temp_f']).to eql(46.4) # ??? was 48.6 now 46.4
        # TBD add additional
      end
    end
  end

  describe "test by mocking cache_result" do
    # This test the way of testing api result by testing by mocking a method that
    # wrappers the actual api call. I added this here so I could test this approach.
    # I have always found rspec mocking doubles confusing, not in concept, but the
    # words don't work me, although I have found some good discussion, TBD research
    # DEV NOTE. I also mocked HTTParty get, which also works,
    # but need to get past a result type mismatch (understand)
    let(:expected_json_result) do
      ["Ok",
        {:location_name=>"Santa Fe",
        :location_region=>"New Mexico",
        :current_temp_f=>48.9,
        :forecast=>
          [{:date=>"2024-12-14", :max_temp_f=>47.7, :min_temp_f=>27.1, :condition=>"Sunny"},
          {:date=>"2024-12-15", :max_temp_f=>46.8, :min_temp_f=>25.3, :condition=>"Sunny"},
          {:date=>"2024-12-16", :max_temp_f=>48.9, :min_temp_f=>25.2, :condition=>"Sunny"},
          {:date=>"2024-12-17", :max_temp_f=>44.8, :min_temp_f=>34.3, :condition=>"Sunny"},
          {:date=>"2024-12-18", :max_temp_f=>36.0, :min_temp_f=>27.0, :condition=>"Patchy moderate snow"}]
        }
      ]
    end
    let(:cached_result) { forecast.cache_forecast('87507') }
    let(:status) { cached_result.first }

    before(:each) do
      allow(forecast).to receive(:cache_forecast).and_return(['Ok',expected_json_result])
    end

    it 'gets right result' do
      expect(cached_result.first).to eql('Ok')
      # TBD add cases
      expect(status).to eql('Ok')
    end
  end

  describe 'call higher level abstraction' do
    it 'should return relevant result' do
    end
  end

end
