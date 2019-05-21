# frozen_string_literal: true

require 'savon'

class Postat
  attr_reader :client

  def initialize
    @client = Savon.client(wsdl: POSTAT_CONFIG[:wsdl],
                           convert_request_keys_to: :none,
                           env_namespace: :soapenv,
                           namespace_identifier: :post,
                           log: true,
                           pretty_print_xml: true,
                           endpoint: POSTAT_CONFIG[:endpoint],
                           namespaces: {
                             'xmlns:post' => 'http://post.ondot.at',
                             'xmlns:arr'  => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays',
                             'xmlns:core' => 'http://Core.Model',
                             'xmlns:ser'  => 'http://schemas.microsoft.com/2003/10/Serialization/'
                           }
    )
  end

  def delete_label(options = {})
    message = []
    options[:shipments]&.each do |shipment|
      row = add_common_params
      row['post:Number'] = shipment[:reference_number]
      message<< { 'post:CancelShipmentRow' => row }
    end
    response = client.call(:cancel_shipments, message: { 'post:shipments' => message })
    handle_response response
  end

  def generate_label(options = {})
    message = add_common_params
    message['post:DeliveryServiceThirdPartyID'] = options[:delivery_code]
    message['post:Number'] = options[:reference_number]
    message['post:ShippingDateTimeFrom'] = (Time.zone.now + 180).iso8601
    message['post:OUShipperAddress'] = add_address(options[:from])
    message['post:OURecipientAddress'] = add_address(options[:to])
    message['post:PrinterObject'] = add_printing_details
    message['post:ColloList'] = add_packages(options[:package])
    # TODO: Look for the new attrs names for: PaymentType, Commodities

    response = client.call(:import_shipment, message: { 'post:row' => message })
    handle_response response
  end

  private

  def handle_response(response)
    response = response.to_hash
    success = response&.dig(:import_shipment_response, :pdf_data) || false
    return response if success
    raise StandardError, [response&.dig(:import_shipment_response, :error_message)]
  end

  def add_printing_details
    {
      'post:LabelFormatID' => '100x200',
      'post:PaperLayoutID' => 'A5',
      'post:LanguageID'    => 'pdf'
    }
  end

  def add_common_params
    {
      'post:ClientID' => POSTAT_CONFIG[:client_id] || raise('postat config missing :client_id'),
      'post:OrgUnitID' => POSTAT_CONFIG[:org_unit_id] || raise('postat config missing :org_unit_id'),
      'post:OrgUnitGuid' => POSTAT_CONFIG[:org_unit_guid] || raise('postat config missing :org_unit_guid')
    }
  end

  def add_address(address)
    {
      'post:AddressLine1' => address[:street].to_s,
      'post:City'         => address[:city].to_s,
      'post:CountryID'    => address[:country].to_s,
      'post:HouseNumber'  => address[:street_no].to_s,
      'post:Name1'        => "#{address[:first_name]} #{address[:last_name]}".squish,
      'post:Name2'        => address[:company].to_s,
      'post:PostalCode'   => address[:zip_code].to_s,
      'post:Tel1'         => address[:phone].to_s,
      'post:Email'        => address[:email].to_s,
      # TODO: look for the new attrs names: CareOf, StateCode
    }
  end

  def add_packages(packages = [])
    package_array = []
    packages = [packages] if packages.is_a?(Hash)
    [*packages].each_with_index do |package, i|
      package_array << {
        'post:ColloRow' => {
          'post:Weight' => package[:weight].to_i,
          'post:Length' => package[:length].to_i,
          'post:Width'  => package[:width].to_i,
          'post:Height' => package[:height].to_i,
        }
      }
    end
    package_array
  end
end
