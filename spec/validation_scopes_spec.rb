require 'spec_helper'

class TestUser
  include ActiveModel::Validations
  include ValidationScopes
  
  attr_accessor :step
  
  attr_accessor :name, :email, :address
  attr_accessor :height, :weight
  attr_accessor :eye_colour, :age

  def step_2?
    step == 2
  end
end

class TestValidator < ActiveModel::EachValidator
  attr_accessor :options
  
  def initialize(options)
    @options = options
    super(options)
  end
  
  def validate(record)
    
  end
end

describe ".validation_scope" do
  
  context "validates_with" do
    before do
      User = Class.new(TestUser) do
        validates_presence_of :address
        validation_scope :if => :step_2? do
          validates_presence_of :name
        end
        validation_scope :if => Proc.new { |u| u.step == 3 } do
          validation_scope :if => Proc.new { |u| !u.height.nil? && u.height > 6 } do
            validates_presence_of :weight
          end
          validates_inclusion_of :eye_colour, :in => ["blue", "brown"], :if => Proc.new { |u| !u.age.nil? && u.age > 20 }
        end
      end
      @user = User.new
      @user.errors[:address].should be
      @user.address = "123 High St"
    end
    
    it "should only validate name when on step 2" do
      @user.tap do |u|
        u.name = nil
        u.should be_valid
        u.step = 2
        u.should be_invalid
        u.name = "Steve"
        u.should be_valid
      end
    end
    
    it "only validates eye colour when on step 3 and age is above 20" do
      @user.tap do |u|
        u.eye_colour = "red"
        u.should be_valid
        u.age = 20
        u.step = 3
        u.should be_valid
        u.age = 21
        u.valid?
        u.should be_invalid
        u.eye_colour = "blue"
        u.should be_valid
      end
    end
    
    it "allows nesting of scopes" do
      @user.tap do |u|
        u.weight = nil
        u.should be_valid
        u.height = 7
        u.should be_valid
        u.step = 3
        u.should be_invalid
        u.errors[:weight].should be
      end
    end
    
    it "calls validates_with with merged scope options" do
      presence_validator = User.validators_on(:name).first
      presence_validator.options.should eq({:if => :step_2?})
    end
  end
  
  context "validate method" do
    before do
      User = Class.new(TestUser) do
        validation_scope :unless => :step_2? do
          validate do
            errors.add(:weight, "Must be greater than 0") unless !@weight.nil? && @weight > 0
          end
        end
      end
    end
    
    it "should only validate weight on step 2" do
      user = User.new
      user.weight = 0
      user.should be_invalid
      user.weight = 1
      user.should be_valid
      
      user.step = 2
      user.weight = 0
      user.should be_valid
    end
  end
  
  context "custom validators" do
    before do
      User = Class.new(TestUser) do
        validation_scope :unless => :step_2?, :some_config_var => 5 do
          validates_with TestValidator, {:attributes => [:name], :some_config_var => 6}
          validation_scope :unless => Proc.new { |u| u.step == 3 } do
            validates_with TestValidator, {:attributes => [:weight], :some_config_var => 7}
          end
        end
      end
      @validator = User.validators_on(:name).first
    end
    
    it "passes the options in" do
      @validator.options[:unless].should eq(:step_2?)
      @validator.options[:some_config_var].should be
    end
    
    it "turns the duplicate options into an array" do
      @validator.options[:some_config_var].should eq([6, 5])
    end
    
    it "works for nested scopes" do
      option = User.validators_on(:weight).first.options[:unless]
      option.size.should eq(2)
      option[0].should eq(:step_2?)
      option[1].should be_an_instance_of(Proc)
    end
  end
  
  after { Object.send(:remove_const, :User) if defined?(User) }
end