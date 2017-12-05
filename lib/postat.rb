# frozen_string_literal: true

require 'savon'

class Postat
  attr_reader :client

  def initialize
    @user = POSTAT_CONFIG[:username] || raise('missing :user')
    @password = POSTAT_CONFIG[:password] || raise('missing :password')
    @guid = POSTAT_CONFIG[:guid] || raise('missing :guid')
    @client = Savon.client wsdl: POSTAT_CONFIG[:wsdl], namespace_identifier: :ryl, convert_request_keys_to: :none
  end

  def delete_label(options = {})
    message = add_common_params
    options[:shipments]&.each do |shipment|
      message[:Shipments] << { 'CancelRequest.Shipment' => shipment }
    end
    response = client.call(:delete_label, message: { ShippingRequest: message })
    handle_response response
  end

  def generate_label(options = {})
    message = add_common_params
    message[:DeliveryProductCode] = options[:delivery_code]
    message[:ReturnProductCode] = options[:return_code]
    message[:Shipments]['Request.Shipment'] = build_shipment(options)
    response = client.call(:create_label, message: { ShippingRequest: message },
                                          attributes: { 'xmlns' => 'http://rylos.lu/' })
    handle_response response
  end

  private

  def handle_response(response)
    response = response.to_hash
    success = response&.dig(:create_label_response, :create_label_result, :was_successful) || false
    return response if success
    message = response&.dig(:create_label_response, :create_label_result, :messages, :message) || []
    raise StandardError, message.values&.join(': ')
  end

  def build_shipment(options = {})
    shipment = {}
    shipment[:Shipper] = add_address(options[:from])
    shipment[:Receiver] = add_address(options[:to])
    shipment[:Date] = (Time.zone.now + 180).iso8601
    shipment[:PaymentType] = 'RECEIVER'
    shipment[:CustomerReference] = options[:reference_number] if options[:delivery_code]
    shipment[:ReturnReference] = options[:reference_number] if options[:return_code]
    shipment[:CurrencyCode] = 'EUR'
    shipment[:AdditionalInsurance] = 0
    commodities = add_commodities(options[:commodities])
    shipment[:Commodities] = commodities unless commodities.empty?
    packages = add_packages(options[:package])
    shipment[:Packages] = packages unless packages.empty?
    shipment[:Label] = { ImageType: 'PDF', PaperFormat: 'A5' }
    shipment
  end

  def add_common_params
    { Credentials: {
      Guid: @guid,
      Username: @user,
      Password: @password
    },
      Carrier: 'POSTAT',
      Shipments: {} }
  end

  def add_address(address)
    { CompanyName: address[:company].to_s,
      PersonName: "#{address[:first_name]} #{address[:last_name]}".squish,
      CareOf: address[:care_of].to_s,
      PhoneNumber: address[:phone].to_s,
      EMailAddress: address[:email].to_s,
      CountryCode: address[:country].to_s,
      StateCode: address[:state_code].to_s,
      PostalCode: address[:zip_code].to_s,
      CityName: address[:city].to_s,
      StreetName: address[:street].to_s,
      StreetNo: address[:street_no].to_s }
  end

  def add_commodities(commodities = [])
    commodity_array = []
    commodities = [commodities] if commodities.is_a?(Hash)
    [*commodities].each_with_index do |commodity, _i|
      commodity_array << {
        'Request.Commodity' => {
          CountryOfManufacture: commodity[:country_iso].to_s,
          CustomsValue: { Amount: commodity[:price], Currency: 'EUR' },
          Weight: { Amount: commodity[:weight].to_i, WeightType: 'KG' },
          Description: commodity[:category].to_s,
          Name: commodity[:name].to_s,
          NumberOfPieces: 1,
          UnitPrice: { Amount: commodity[:price], Currency: 'EUR' },
          Quantity: 1
        }
      }
    end
    commodity_array
  end

  def add_packages(packages = [])
    package_array = []
    packages = [packages] if packages.is_a?(Hash)
    [*packages].each_with_index do |package, i|
      package_array << {
        'Request.Package' => {
          SequenceNumber: i += 1,
          GroupPackageCount: packages.size,
          Weight: { Amount: package[:weight].to_i, WeightType: 'KG' },
          Length: package[:length].to_i,
          Width: package[:width].to_i,
          Height: package[:height].to_i,
          DimensionType: 'CM',
          PackageType: 'CARTON'
        }
      }
    end
    package_array
  end
end
