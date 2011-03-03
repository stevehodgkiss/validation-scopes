require 'spec_helper'
require 'active_model'

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
  
  protected
  
  def self.method_with_options(options)
    options
  end
end

describe ValidationScopes do
  
  before do
    TestClass = Class.new do
      include ValidationScopes
      
      def self.method_with_options(options)
        options
      end
      
      def self.method_with_multiple_options(*options)
        options
      end
    end
  end
  
  it "merges method no options" do
    TestClass.class_eval do
      validation_scope :if => 1 do |v|
        v.method_with_options.should == {:if => 1}
      end
    end
  end
  
  it "merges method with options" do
    TestClass.class_eval do
      validation_scope :if => 1 do |v|
        v.method_with_options(:if => 2).should == {:if => [2, 1]}
      end
    end
  end
  
  it "merges with multiple options" do
    TestClass.class_eval do
      validation_scope :if => 1 do |v|
        v.method_with_multiple_options(:name, :if => 2).should == [:name, {:if => [2, 1]}]
      end
    end
  end
  
  it "merges nested scope with no method options" do
    TestClass.class_eval do
      validation_scope :if => 1 do |v|
        v.validation_scope :if => 2 do |s|
          s.method_with_options.should == {:if => [2, 1]}
        end
      end
    end
  end
  
  it "merges nested scope with method options" do
    TestClass.class_eval do
      validation_scope :if => 1 do |v|
        v.validation_scope :if => 2 do |s|
          s.method_with_options(:if => 3, :unless => 6).should == {:if => [3, 2, 1], :unless => 6}
        end
      end
    end
  end
  
  it "merges deep nested scope with method options" do
    TestClass.class_eval do
      validation_scope :if => 1 do |v|
        v.validation_scope :if => 2 do |s|
          s.validation_scope :unless => 6 do |u|
            u.method_with_options(:if => 3).should == {:if => [3, 2, 1], :unless => 6}
          end
        end
      end
    end
  end
  
  it "fails if called without a block parameter" do
    expect {
      TestClass.class_eval do
        validation_scope :if => 1 do
        
        end
      end
    }.to raise_error
  end
  
  after { Object.send(:remove_const, :TestClass) }
end

describe ValidationScopes, "with AM" do
  
  context "validates_with" do
    before do
      User = Class.new(TestUser) do
        validates_presence_of :address
        validation_scope :if => :step_2? do |v|
          v.validates_presence_of :name
        end
        validation_scope :if => Proc.new { |u| u.step == 3 } do |v|
          v.validation_scope :if => Proc.new { |u| !u.height.nil? && u.height > 6 } do |h|
            h.validates_presence_of :weight
          end
          v.validates_inclusion_of :eye_colour, :in => ["blue", "brown"], :if => Proc.new { |u| !u.age.nil? && u.age > 20 }
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
  end
  
  after { Object.send(:remove_const, :User) }
end