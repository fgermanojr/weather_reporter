require 'rails_helper'

RSpec.describe Forecast, type: :model do
  # test validations
  describe ('good request') do
    let(:forecast) { Forecast.new(zipcode: '87507') }

    it 'is valid' do
      expect(forecast).to be_valid
    end
  end

  describe ('bad request,wrong length') do
    let(:forecast) { Forecast.new(zipcode: '8750') }

    it 'is not valid' do
      expect(forecast.valid?).to be_falsey
    end
  end

  describe ('bad request, not numeric') do
    let(:forecast) { Forecast.new(zipcode: '8750A') }

    it 'is not valid' do
      expect(forecast.valid?).to be_falsey
    end
  end

  describe ('bad request, blank') do
    let(:forecast) { Forecast.new(zipcode: '') }

    it 'is not valid' do
      expect(forecast.valid?).to be_falsey
    end
  end

  describe ('bad request, missing') do
    let(:forecast) { Forecast.new(zipcode: nil) }

    it 'is not valid' do
      expect(forecast.valid?).to be_falsey
    end
  end
end
