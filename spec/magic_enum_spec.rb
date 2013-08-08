require 'bundler/setup'
require 'magic_enum'

module MagicEnumHelper
  class TestModelBase
    extend MagicEnum::ClassMethods
    Statuses = { :unknown => 0, :draft => 1, :published => 2 }

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

  it 'should define methods to get and set enum field' do
    TestModelSimple.should be_method_defined(:status)
    TestModelSimple.should be_method_defined(:status=)
  end

  it 'should store enum value using [] operation on model' do
    @model.status = :draft
    @model[:status].should == 1
    @model.status.should == :draft
    @model.status = :unknown
    @model[:status].should == 0
    @model.status.should == :unknown
  end

  it 'should store enum value if key is given as string' do
    @model.status = 'draft'
    @model[:status].should == 1
    @model.status.should == :draft
    @model.status = 'unknown'
    @model[:status].should == 0
    @model.status.should == :unknown
  end

  it 'should store enum value if key is given as integer equivalent' do
    @model.status = 1
    @model[:status].should == 1
    @model.status.should == :draft
    @model.status = 0
    @model[:status].should == 0
    @model.status.should == :unknown
  end

  it 'should not define simple accessors by default' do
    @model.should_not respond_to(:unknown?)
    @model.should_not respond_to(:draft?)
    @model.should_not respond_to(:published?)
  end

  it 'should not raise error when invalid value received' do
    lambda { @model.status = :invalid }.should_not raise_error
  end

  it 'should use default value 0 when invalid value received or current state invalid' do
    @model[:status] = -1
    @model.status.should == :unknown
    @model.status = :published
    @model.status.should == :published
    @model.status = :invalid
    @model[:status].should == 0
    @model.status.should == :unknown
  end

  it 'should return string value when _name method called' do
    @model.status_name.should == 'unknown'
    @model.status = :published
    @model.status_name.should == 'published'
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
    @model.status.should == :published
  end

  it 'should use default value when invalid value received' do
    @model.status = nil
    @model.status.should == :published
    @model.status = :invalid
    @model.status.should == :published
    @model[:status].should == 2
  end

  it 'should not interpret nil in the same way as 0' do
    @model[:status].should be_nil
    @model.status.should == :published
    @model[:status] = 0
    @model.status.should == :unknown
  end
end

describe 'Model with magic enum and default value specified as nil' do
  include MagicEnumHelper

  class TestModelWithDefaultNil < MagicEnumHelper::TestModelBase
    SimpleStatuses = { :unknown => 0, :draft => 1, :published => 2, :simple => nil }
    define_enum :simple_status, :default => nil
  end

  before do
    @model = TestModelWithDefaultNil.new
  end

  it 'should use default value when current state is invalid' do
    @model[:simple_status] = -1
    @model.simple_status.should == :simple
  end

  it 'should use default value when invalid value received' do
    @model.simple_status = nil
    @model.simple_status.should == :simple
    @model.simple_status = :invalid
    @model.simple_status.should == :simple
    @model[:simple_status].should be_nil
  end

  it 'should not interpret nil in the same way as 0' do
    @model[:simple_status].should be_nil
    @model.simple_status.should == :simple
    @model[:simple_status] = 0
    @model.simple_status.should == :unknown
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
      lambda { @model.status = :draft }.should_not raise_error
    end

    it 'should raise error when invalid value received' do
      lambda { @model.status = :invalid }.should raise_error(ArgumentError)
    end

    it 'should show error description when invalid value received' do
      begin
        @model.status = :invalid
      rescue => e
        e.message.should == 'Invalid value "invalid" for :status attribute of the TestModelWithRaiseOnInvalid model'
      end
    end
  end

  context 'with integer value' do
    it 'should not raise error when valid value received' do
      lambda { @model.status = 1 }.should_not raise_error
    end

    it 'should raise error when invalid value received' do
      lambda { @model.status = 4 }.should raise_error(ArgumentError)
    end

    it 'should show error description when invalid value received' do
      begin
        @model.status = 4
      rescue => e
        e.message.should == 'Invalid value "4" for :status attribute of the TestModelWithRaiseOnInvalid model'
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
    @model.should respond_to(:unknown?)
    @model.should respond_to(:draft?)
    @model.should respond_to(:published?)
  end
end

describe 'Model with magic enum and named_scopes option specified' do
  include MagicEnumHelper

  class TestModelWithNamedScopes < ActiveRecord::Base
    Statuses = { :unknown => 0, :draft => 1, :published => 2 }
    define_enum :status, :named_scopes => true
  end

  it 'should define named_scopes' do
    TestModelWithNamedScopes.should respond_to(:unknowns)
    TestModelWithNamedScopes.should respond_to(:drafts)
    TestModelWithNamedScopes.should respond_to(:publisheds)
    TestModelWithNamedScopes.should respond_to(:of_status)
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
    @model.status.should == :user
    @model[:status].should == 'u'
    @model.status = :admin
    @model.status.should == :admin
    @model[:status].should == 'a'
  end

  it 'should use option with min value as default' do
    @model.status = :invalid
    @model.status.should == :admin
  end
end

describe 'ActiveRecord::Base class' do
  it 'should include MagicEnum methods' do
    ActiveRecord::Base.should respond_to(:define_enum)
  end
end
