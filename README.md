# Fencer
Fencer is designed to process rows of fixed-length and delimited text 
data, splitting at designated termination points, converting field values
where required and making fields available through named object accessors.

Row formats are defined by subclassing Fencer::Base and using the DSL
provided.

## Example
    class EmployeeRecord < Fencer::Base
     field :department, 50, :string
     field :name, 20, -> s { s.split }
     space 2
     field :age, 4, :integer
    end
    
`field` takes 3 arguments: a field name, the field length and an (optional)
converter.

## Field Conversion
`Fencer::Base::Converters` is a `Hash` that defines some commonly-used 
converters. It's left un-frozen, so it can be extended as required.

Short-cut methods for the default field types are also available:

    class EmployeeRecord < Fencer::Base
      string  :department, 20      => String
      integer :age, 2              => Integer
      decimal :salary, 10          => BigDecimal
    end

Additionally, custom conversions can be defined by passing a `lambda`
as the final argument.

## Usage

Records are extracted on initialisation:

    raw_string = "EXAMPLE FORMAT      10   300.04"
    fields     = EmployeeRecord.new(raw_string)

And are directly accessible thereafter:
    
    fields.department # => "EXAMPLE FORMAT"
    fields.age        # => 2
    fields.salary     # => BigDecimal("300.04")

In the case of importing delimiter-separated data, passing the delimiting
character as the second argument to `new` will yield the desired result 
without any change of layout:

    raw_string = "EXAMPLE FORMAT|10|300.04"
    fields     = EmployeeRecord.new(raw_string, "|")
    
    fields.department # => "EXAMPLE FORMAT"
    fields.age        # => 2
    fields.salary     # => BigDecimal("300.04")


## Known Deficiencies

Currently, Fencer works with Ruby 1.9 only. Sorry. I wanted Hashes that
preserve field-order. Plus, the newer syntax is pretty.

Fencer is also blissfully unaware of any sort of encoding. This is a planned  
feature for the 1.0 release.
