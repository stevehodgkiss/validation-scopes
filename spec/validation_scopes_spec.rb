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

describe ".validation_scope" do
  
  context "validates_with" do
    before do
      User = Class.new(TestUser) do
        validates_presence_of :address
        validation_scope :if => :step_2? do
          validates_presence_of :name
        end
        validation_scope :if => Proc.new { |u| u.step == 3 } do
          validates_inclusion_of :eye_colour, :in => ["blue", "brown"], :if => Proc.new { |u| !u.age.nil? && u.age > 20 }
        end
      end
      @user = User.new
      @user.errors[:address].should be
      @user.address = "123 High St"
    end
    
    it "should only validate name when on step 2" do
      @user.name = nil
      @user.should be_valid
      @user.step = 2
      @user.should be_invalid
      @user.name = "Steve"
      @user.should be_valid
    end
    
    it "only validates eye colour when on step 3 and age is above 20" do
      @user.eye_colour = nil
      @user.should be_valid
      @user.step = 3
      @user.eye_colour = "red"
      @user.should be_valid
      @user.age = 21
      @user.should be_invalid
      @user.eye_colour = "blue"
      @user.should be_valid
    end
    
    after { Object.send(:remove_const, :User) }
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
    
    after { Object.send(:remove_const, :User) }
  end
end