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
    
    def initialize(str, delimiter = nil)
      @values    = {}
      @delimiter = delimiter
      @str       = str

      parse!
    end
    
    def to_hash
      @values
    end
    
    private

    def parse!
      if @str.kind_of?(Array)
        raw_values = @str
      elsif @delimiter
        raw_values = @str.split(@delimiter)
      else
        unpack_phrase = self.class.fields.values.map { |s| "A#{s[:size]}" }.join
        raw_values = @str.unpack(unpack_phrase)
      end

      _index = 0      
      self.class.fields.each do |name, opts|        
        unless opts[:space]          
          _conversion_proc = case opts[:convert]
            when Symbol then Converters[opts[:convert]]
            when Proc   then opts[:convert]
            else nil
          end 
          
          @values[name] = _conversion_proc ? _conversion_proc.call(raw_values[_index]) : raw_values[_index]
        end

        _index += 1 unless opts[:space] && (@delimiter || @str.kind_of?(Array))
      end
    end
  end
end
