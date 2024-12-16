require 'rails_helper'

RSpec.describe "Forecasts", type: :system do
  # DEBUG, at some point. Fails to find a valid spec; works in request spec.
  # VCR.configure do |config|
  #   config.cassette_library_dir = 'spec/cassettes'
  #   config.hook_into :webmock
  #   config.debug_logger = $stderr # Added, is it working?
  # end

  # before do
  #   driven_by(:selenium_chrome_headless)
  # end

  # # pending "add enter zipcode, see results #{__FILE__}"

  # it "lands query page, displays result page" do
  #   VCR.use_cassette('forecast_get', record: :all) do
  #     visit "/forecasts/new"

  #     fill_in "forecast_zipcode", :with => "87507"
  #     click_button "Create Forecast"

  #     # land on result page
  #     expect(page).to have_text("Santa Fe")
  #     # TBD add additional
  #   end
    
  # end

  # use mocking of result of api call to get stub result
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

  let(:forecast) {Forecast.new(zipcode: '87507')}

  before(:each) do
    allow(forecast).to receive(:cache_forecast).and_return(['Ok',expected_json_result])
  end

  it 'lands result page with valid results' do
    visit "/forecasts/new"

    fill_in "forecast_zipcode", :with => "87507"
    click_button "Create Forecast"

    # land on result page
    expect(page).to have_text("Santa Fe")
    expect(page).to have_text("2024-12-19")
    # page.should have_button('New Request')
    page.find(:xpath, '//a[@href="/forecasts/new"]')
    page.should have_link("New Request", :href => '/forecasts/new')
    elem = page.find(:xpath, "//table[@id='forecast']/tbody/tr[1]/td[4]")
    expect(elem.text()).to eql('Sunny')
    expect(page).to have_selector(:xpath, "//table[@id='forecast']/tbody/tr[1]/td[4]")
    # TBD add additional, using xpath selectors
  end
end
