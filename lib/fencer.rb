require "bigdecimal"
require "fencer/version"

module Fencer
  class Base
    Converters = {
      string:  -> s { s.strip },
      integer: -> s { s.to_i },
      decimal: -> s { BigDecimal(s) },
    }

    class << self
      attr_reader :fields

      def inherited(subclass)
        subclass.instance_variable_set(:@fields, {})
      end

      def field(name, size, convert = nil)
        # error handling, ahoy!
        raise "#{name} already defined as a field on #{self.name}" if fields.has_key?(name)

        unless convert.nil? || Converters.has_key?(convert) || convert.is_a?(Proc)
          raise "Invalid converter"
        end

        fields[name] = { size: size, convert: convert }

        # create our attr method
        define_method(name) { @values[name] }
      end

      def space(size)
        fields[:"_#{fields.length.succ}"] = { size: size, space: true }
      end

      def string(name, size)
        field(name, size, :string)
      end

      def integer(name, size)
        field(name, size, :integer)
      end

      def decimal(name, size)
        field(name, size, :decimal)
      end
    end

    def initialize(raw_data, delimiter = nil, forced_encoding = nil)
      @values          = {}
      @delimiter       = delimiter

      if forced_encoding
        @raw_data = raw_data.encode(forced_encoding, invalid: :replace)
      else
        @raw_data = raw_data
      end

      parse!
    end

    def to_hash
      @values
    end

    private

    def parse!
      if @raw_data.kind_of?(Array)
        raw_values = @raw_data
      elsif @delimiter
        raw_values = @raw_data.split(@delimiter)
      else
        unpack_phrase = self.class.fields.values.map { |s| "A#{s[:size]}" }.join
        raw_values = @raw_data.unpack(unpack_phrase)
      end

      field_index = 0
      self.class.fields.each do |name, opts|
        unless opts[:space]
          converter = case opts[:convert]
            when Symbol then Converters[opts[:convert]]
            when Proc   then opts[:convert]
            else nil
          end

          @values[name] = converter ? converter.call(raw_values[field_index]) : raw_values[field_index]
        end

        field_index += 1 unless opts[:space] && (@delimiter || @raw_data.kind_of?(Array))
      end
    end
  end
end
