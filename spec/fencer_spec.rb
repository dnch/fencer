# require 'rubygems'

Bundler.require(:default, :development)

require 'rspec'
require 'fencer'

describe Fencer do

  class EmployeeRecord < Fencer::Base
    string :name, 20
    string :department, 20
    space 2
    field :employment_date, 8, -> s { dasherise_ymd(s) }
    integer :id_number, 6
    decimal :leave_accrued, 11

    class << self
      def dasherise_ymd(str)
        str.gsub(/([0-9]{4})([0-9]{2})([0-9]{2})/) { "#{$1}-#{$2}-#{$3}" }
      end
    end
  end

  let(:name)            { "Ford Prefect" }
  let(:department)      { "Publication" }
  let(:employment_date) { "20120525" }
  let(:id_number)       { "42" }
  let(:leave_accrued)   { "1484.33" }

  it "has many wonderful features" do

    compiled_record = name.ljust(20)
    compiled_record << department.ljust(20)
    compiled_record <<  "  "
    compiled_record << employment_date
    compiled_record << id_number.rjust(6, '0')
    compiled_record << leave_accrued.rjust(11, '0')

    # auto parsing
    values = EmployeeRecord.new(compiled_record)

    # individual accessors for each field
    values.name.should eq(name)
    values.department.should eq(department)
    values.employment_date.should eq("2012-05-25")
    values.id_number.should eq(id_number.to_i)
    values.leave_accrued.should eq(BigDecimal(leave_accrued))

    # export our values to a hash
    values.to_hash.should eq({
      name: name,
      department: department,
      employment_date: "2012-05-25",
      id_number: id_number.to_i,
      leave_accrued: BigDecimal(leave_accrued),
    })
  end

  it "also works when parsing arbitrarily delimited fields!" do
    compiled_record = [
      name, department, employment_date, id_number, leave_accrued
    ].join("|")
    
    values = EmployeeRecord.new(compiled_record, "|")
    
    values.name.should eq(name)
    values.department.should eq(department)
    values.employment_date.should eq("2012-05-25")
    values.id_number.should eq(id_number.to_i)
    values.leave_accrued.should eq(BigDecimal(leave_accrued))
  end

  it "also describes arrays!" do
    compiled_record = [
      name, department, employment_date, id_number, leave_accrued
    ]

    values = EmployeeRecord.new(compiled_record)

    values.name.should eq(name)
    values.department.should eq(department)
    values.employment_date.should eq("2012-05-25")
    values.id_number.should eq(id_number.to_i)
    values.leave_accrued.should eq(BigDecimal(leave_accrued))
  end
end


class FencerBaseTest < Fencer::Base
  class << self      
    def reset_fields!
      @fields = {}
    end
  end
end

describe Fencer::Base do
  before(:each) do
    subject.reset_fields!
  end

  subject { FencerBaseTest }

  it "#field adds fields to the internal register" do
    subject.field(:derp, 1)
    subject.fields.should have_key(:derp)
  end

  it "#field adds an instance access method" do
    subject.field(:derp, 1)

    instance = subject.new("")
    instance.should respond_to(:derp)
    instance.should_not respond_to(:herp)
  end

  it "raises an error when the size attribute is omitted" do
    expect { subject.field(:derp) }.to raise_error
  end

  it "raises an error when duplicate keys are defined" do
    subject.field(:derp, 1)
    expect { subject.field(:derp, 1) }.to raise_error
  end

  context "when using shortcut methods" do
    it "has a shortcut for string fields" do
      subject.string(:derp, 1)
      subject.fields.should have_key(:derp)
      subject.fields[:derp][:convert].should be :string
    end

    it "has a shortcut for integer fields" do
      subject.integer(:derp, 1)
      subject.fields.should have_key(:derp)
      subject.fields[:derp][:convert].should be :integer
    end

    it "has a shortcut for decimal fields" do
      subject.decimal(:derp, 1)
      subject.fields.should have_key(:derp)
      subject.fields[:derp][:convert].should be :decimal
    end
  end

  context "when setting an invalid conversion argument" do
    it "raises an error if the symbol is not registered" do
      expect { subject.field(:derp, 1, :to_date) }.to raise_error
    end

    it "raises an error if the argument is not a lambda" do
      expect { subject.field(:derp, 1, "") }.to raise_error
    end
  end
end