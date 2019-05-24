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
      row = init_message
      row['post:Number'] = shipment[:reference_number]
      add_common_params(row)
      message<< { 'post:CancelShipmentRow' => row }
    end
    response = client.call(:cancel_shipments, message: { 'post:shipments' => message })
    handle_response(response, action: :cancel_shipments)
  end

  # NOTE: be careful with the order of attributes to avoid fake missing attribute errors
  def generate_label(options = {})
    message = init_message
    message['post:DeliveryServiceThirdPartyID'] = options[:delivery_code]
    message['post:Number'] = options[:reference_number]
    message['post:ColloList'] = add_packages(options[:package])
    # message['post:ShippingDateTimeFrom'] = (Time.zone.now + 180).iso8601
    message['post:OURecipientAddress'] = add_address(options[:to])
    message['post:OUShipperAddress'] = add_address(options[:from])
    add_common_params(message)
    message['post:PrinterObject'] = add_printing_details
    # TODO: Look for the new attrs names for: PaymentType, Commodities

    response = client.call(:import_shipment, message: { 'post:row' => message })
    handle_response response
  end

  private

  def handle_response(response, action: :import_shipment)
    action_name = "#{action}_response".to_sym
    response = response.to_hash
    error = response&.dig(action_name, :error_message)
    error ||= response&.dig(action_name, :error_code)
    return response if error.blank?
    raise StandardError, [error]
  end

  def add_printing_details
    {
      'post:LanguageID'    => 'pdf',
      'post:LabelFormatID' => '100x200',
      'post:PaperLayoutID' => 'A5'
    }
  end

  def init_message
    { 'post:ClientID' => POSTAT_CONFIG[:client_id] || raise('postat config missing :client_id') }
  end

  def add_common_params(data)
    data['post:OrgUnitGuid'] = POSTAT_CONFIG[:org_unit_guid] || raise('postat config missing :org_unit_guid')
    data['post:OrgUnitID'] = POSTAT_CONFIG[:org_unit_id] || raise('postat config missing :org_unit_id')
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
