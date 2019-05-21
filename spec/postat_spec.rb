require File.expand_path('spec/spec_helper')
require 'active_support/all'

describe Postat do
  let(:postat) { double(:postat) }
  before { stub_settings }
  before do
    allow(Savon).to receive(:client).and_return(postat)
    allow(Time).to receive(:zone).and_return(Time)
  end

  describe '#delete_label' do
    it 'success label' do
      data = {
        cancel_shipments_response: { error_message: nil, success: true }
      }
      stub_postat(:cancel_shipments, data)
      res = Postat.new.delete_label(shipments: [{ reference_number: 1 }])
      expect(res[:cancel_shipments_response][:error_message].nil?).to be_truthy
    end

    it 'error label' do
      data = {
        cancel_shipments_response: { error_message: 'err msg', success: true }
      }
      stub_postat(:cancel_shipments, data)
      expect { Postat.new.delete_label(shipments: [{ reference_number: 1 }]) }
        .to raise_error(StandardError)
    end
  end

  describe '#generate_label' do
    it 'success label' do
      stub_postat(:import_shipment, success_res_label)
      res = Postat.new.generate_label(label_options)
      expect(res[:import_shipment_response][:error_message].nil?).to be_truthy
    end

    it 'error label' do
      data = {
        import_shipment_response: { error_message: 'err msg', success: true }
      }
      stub_postat(:import_shipment, data)
      expect { Postat.new.generate_label(shipments: [{ reference_number: 1 }]) }
        .to raise_error(StandardError)
    end
  end

  private

  def stub_postat(action, return_data)
    allow(postat).to receive(:call).with(action, anything)
                                   .and_return(return_data)
  end

  def stub_settings
    config = {
      client_id: '1',
      org_unit_id: '1',
      org_unit_guid: '1'
    }
    stub_const('POSTAT_CONFIG', config)
  end

  def label_options
    package = {
      length: 1,
      width: 1,
      height: 1,
      weight: 1,
      description: 'Clothing'
    }

    address = {
      first_name: 'lorem',
      last_name: 'ipsum',
      street: 'str',
      street_no: 10,
      zip_code: '0000',
      city: 'Hamburg',
      country: 'de'
    }

    {
      delivery_code: 28,
      package: [package],
      reference_number: 'Inbound',
      create_shipping_label: true,
      from: address,
      to: address
    }
  end

  def success_res_label
    data = {
      pdfData: '......',
      import_shipment_result: {
        collo_row: [
          {
            collo_code_list: {
              collo_code_row: {
                code: '010052000000280964922303',
                number_type_id: '0fcbf432-c95b-467d-b397-aef3d862b5a3'
              }
            }
          }
        ]
      }
    }
    { import_shipment_response: data }
  end
end
