require 'bundler/setup'
require 'magic_enum'

module MagicEnumHelper
  class TestModelBase
    extend MagicEnum::ClassMethods
    STATUSES = { :unknown => 0, :draft => 1, :published => 2 }

    def [](attr_name)
      @status
    end

    def []=(attr_name, value)
      @status = value
    end
  end
end

describe 'Model with magic enum' do
  include MagicEnumHelper

  class TestModelSimple < MagicEnumHelper::TestModelBase
    define_enum :status
  end

  before do
    @model = TestModelSimple.new
  end

  it 'should define helper class methods' do
    expect(TestModelSimple.status_value(:draft)).to eq(1)
    expect(TestModelSimple.status_value('draft')).to eq(1)
    expect(TestModelSimple.status_value(:invalid)).to be_nil

    expect(TestModelSimple.status_by_value(1)).to eq(:draft)
    expect(TestModelSimple.status_by_value(-1)).to be_nil
  end

  it 'should define methods to get and set enum field' do
    expect(TestModelSimple.method_defined?(:status)).to be_true
    expect(TestModelSimple.method_defined?(:status=)).to be_true
    expect(TestModelSimple.method_defined?(:status_name)).to be_true
    expect(TestModelSimple.method_defined?(:status_value)).to be_true
  end

  it 'should store enum value using [] operation on model' do
    @model.status = :draft
    expect(@model[:status]).to eq(1)
    expect(@model.status).to eq(:draft)
    @model.status = :unknown
    expect(@model[:status]).to eq(0)
    expect(@model.status).to eq(:unknown)
  end

  it 'should store enum value if key is given as string' do
    @model.status = 'draft'
    expect(@model[:status]).to eq(1)
    expect(@model.status).to eq(:draft)
    @model.status = 'unknown'
    expect(@model[:status]).to eq(0)
    expect(@model.status).to eq(:unknown)
  end

  it 'should store enum value if key is given as integer equivalent' do
    @model.status = 1
    expect(@model[:status]).to eq(1)
    expect(@model.status).to eq(:draft)
    @model.status = 0
    expect(@model[:status]).to eq(0)
    expect(@model.status).to eq(:unknown)
  end

  it 'should not define simple accessors by default' do
    expect(@model).to_not respond_to(:unknown?)
    expect(@model).to_not respond_to(:draft?)
    expect(@model).to_not respond_to(:published?)
  end

  it 'should not raise error when invalid value received' do
    expect { @model.status = :invalid }.to_not raise_error
  end

  it 'should use default value 0 when invalid value received or current state invalid' do
    @model[:status] = -1
    expect(@model.status).to eq(:unknown)
    @model.status = :published
    expect(@model.status).to eq(:published)
    @model.status = :invalid
    expect(@model[:status]).to eq(0)
    expect(@model.status).to eq(:unknown)
  end

  it 'should return string value when _name method called' do
    expect(@model.status_name).to eq('unknown')
    @model.status = :published
    expect(@model.status_name).to eq('published')
  end

  it 'should return value when _value method called' do
    expect(@model.status_value).to eq(0)
    @model.status = :published
    expect(@model.status_value).to eq(2)
  end

  it 'should not define named scopes by default' do
    TestModelSimple.should_not_receive(:named_scope)
    TestModelSimple.should_not_receive(:scope)
  end
end

describe 'Model with magic enum and default value specified' do
  include MagicEnumHelper

  class TestModelWithDefault < MagicEnumHelper::TestModelBase
    define_enum :status, :default => 2
  end

  before do
    @model = TestModelWithDefault.new
  end

  it 'should use default value when current state is invalid' do
    @model[:status] = -1
    expect(@model.status).to eq(:published)
  end

  it 'should use default value when invalid value received' do
    @model.status = nil
    expect(@model.status).to eq(:published)
    @model.status = :invalid
    expect(@model.status).to eq(:published)
    expect(@model[:status]).to eq(2)
  end

  it 'should not interpret nil in the same way as 0' do
    expect(@model[:status]).to be_nil
    expect(@model.status).to eq(:published)
    @model[:status] = 0
    expect(@model.status).to eq(:unknown)
  end
end

describe 'Model with magic enum and default value specified as a symbol' do
  include MagicEnumHelper

  class TestModelWithDefault < MagicEnumHelper::TestModelBase
    define_enum :status, :default => :published
  end

  before do
    @model = TestModelWithDefault.new
  end

  it 'should use default value when current state is invalid' do
    @model[:status] = -1
    expect(@model.status).to eq(:published)
  end

  it 'should use default value when invalid value received' do
    @model.status = nil
    expect(@model.status).to eq(:published)
    @model.status = :invalid
    expect(@model.status).to eq(:published)
    expect(@model[:status]).to eq(2)
  end

  it 'should not interpret nil in the same way as 0' do
    expect(@model[:status]).to be_nil
    expect(@model.status).to eq(:published)
    @model[:status] = 0
    expect(@model.status).to eq(:unknown)
  end
end

describe 'Model with magic enum and default value specified as nil' do
  include MagicEnumHelper

  class TestModelWithDefaultNil < MagicEnumHelper::TestModelBase
    SIMPLE_STATUSES = { :unknown => 0, :draft => 1, :published => 2, :simple => nil }
    define_enum :simple_status, :default => nil
  end

  before do
    @model = TestModelWithDefaultNil.new
  end

  it 'should use default value when current state is invalid' do
    @model[:simple_status] = -1
    expect(@model.simple_status).to eq(:simple)
  end

  it 'should use default value when invalid value received' do
    @model.simple_status = nil
    expect(@model.simple_status).to eq(:simple)
    @model.simple_status = :invalid
    expect(@model.simple_status).to eq(:simple)
    expect(@model[:simple_status]).to be_nil
  end

  it 'should not interpret nil in the same way as 0' do
    expect(@model[:simple_status]).to be_nil
    expect(@model.simple_status).to eq(:simple)
    @model[:simple_status] = 0
    expect(@model.simple_status).to eq(:unknown)
  end
end

describe 'Model with magic enum and raise_on_invalid option specified' do
  include MagicEnumHelper

  class TestModelWithRaiseOnInvalid < MagicEnumHelper::TestModelBase
    define_enum :status, :raise_on_invalid => true
  end

  before do
    @model = TestModelWithRaiseOnInvalid.new
  end

  context 'with symbol value' do
    it 'should not raise error when valid value received' do
      expect { @model.status = :draft }.to_not raise_error
    end

    it 'should raise error when invalid value received' do
      expect { @model.status = :invalid }.to raise_error(ArgumentError)
    end

    it 'should show error description when invalid value received' do
      begin
        @model.status = :invalid
      rescue => e
        expect(e.message).to eq('Invalid value "invalid" for :status attribute of the TestModelWithRaiseOnInvalid model')
      end
    end
  end

  context 'with integer value' do
    it 'should not raise error when valid value received' do
      expect { @model.status = 1 }.to_not raise_error
    end

    it 'should raise error when invalid value received' do
      expect { @model.status = 4 }.to raise_error(ArgumentError)
    end

    it 'should show error description when invalid value received' do
      begin
        @model.status = 4
      rescue => e
        expect(e.message).to eq('Invalid value "4" for :status attribute of the TestModelWithRaiseOnInvalid model')
      end
    end
  end
end


describe 'Model with magic enum and simple_accessors option specified' do
  include MagicEnumHelper

  class TestModelWithSimpleAccessors < MagicEnumHelper::TestModelBase
    define_enum :status, :simple_accessors => true
  end

  before do
    @model = TestModelWithSimpleAccessors.new
  end

  it 'should define simple accessors by default' do
    expect(@model).to respond_to(:unknown?)
    expect(@model).to respond_to(:draft?)
    expect(@model).to respond_to(:published?)
  end
end

describe 'Model with magic enum and named_scopes option specified' do
  include MagicEnumHelper

  class TestModelWithNamedScopes < ActiveRecord::Base
    STATUSES = { :unknown => 0, :draft => 1, :published => 2 }
    define_enum :status, :named_scopes => true
  end

  it 'should define named_scopes' do
    expect(TestModelWithNamedScopes).to respond_to(:unknowns)
    expect(TestModelWithNamedScopes).to respond_to(:drafts)
    expect(TestModelWithNamedScopes).to respond_to(:publisheds)
    expect(TestModelWithNamedScopes).to respond_to(:of_status)
  end
end

describe 'Model with magic enum and enum option specified' do
  include MagicEnumHelper

  class TestModelEnumOption < MagicEnumHelper::TestModelBase
    Roles = {
      :user => 'u',
      :admin => 'a'
    }
    define_enum :status, :enum => 'Roles'
  end

  before do
    @model = TestModelEnumOption.new
  end

  it 'should use custom enum' do
    @model.status = :user
    expect(@model.status).to eq(:user)
    expect(@model[:status]).to eq('u')
    @model.status = :admin
    expect(@model.status).to eq(:admin)
    expect(@model[:status]).to eq('a')
  end

  it 'should use option with min value as default' do
    @model.status = :invalid
    expect(@model.status).to eq(:admin)
  end
end

describe 'Model with two magic enums sharing a single enum hash' do
  include MagicEnumHelper

  class TestModelSimple < MagicEnumHelper::TestModelBase
    define_enum :status
    define_enum :another_status, :enum => 'STATUSES'
  end

  before do
    @model = TestModelSimple.new
  end

  it 'should define helper class methods' do
    expect(TestModelSimple.status_value(:draft)).to eq(1)
    expect(TestModelSimple.another_status_value(:draft)).to eq(1)

    expect(TestModelSimple.status_by_value(1)).to eq(:draft)
    expect(TestModelSimple.another_status_by_value(1)).to eq(:draft)
  end
end

describe 'ActiveRecord::Base class' do
  it 'should include MagicEnum methods' do
    expect(ActiveRecord::Base).to respond_to(:define_enum)
  end
end
