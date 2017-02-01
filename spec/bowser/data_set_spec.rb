require 'bowser/data_set'

module Bowser
  describe DataSet do
    it 'accesses camelized attributes' do
      native = `{ firstName: 'foo' }`
      data_set = described_class.new(native)

      expect(data_set[:first_name]).to eq 'foo'
    end

    it 'sets camelized attributes' do
      native = `{}`
      data_set = described_class.new(native)
      data_set[:first_name] = 'foo'

      expect(`#{data_set.to_n}.firstName`).to eq 'foo'
    end

    it 'accesses attributes via accessor methods' do
      native = `{ firstName: 'foo' }`
      data_set = described_class.new(native)

      expect(data_set.first_name).to eq 'foo'
    end

    it 'sets camelized attributes via setter method' do
      native = `{}`
      data_set = described_class.new(native)
      data_set.first_name = 'foo'

      expect(`#{data_set.to_n}.firstName`).to eq 'foo'
    end
  end
end
