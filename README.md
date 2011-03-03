# Validation Scopes

Validation Scopes allows you to remove duplication in validations by grouping validations that share the same conditions. It works the same way as ActiveSupport's OptionMerger does, except instead of replacing duplicate keys it groups them into an array. This is so that nested if conditions work inside ActiveModel validations. Example, with result shown in comments:

    class Car < ActiveRecord::Base
      validation_scope :if => Proc.new { |u| u.step == 2 } do |v|
        v.validates_presence_of :variant # , :if => Proc.new { |u| u.step == 2 }
        v.validation_scope :if => :something? do |s|
          s.validates_presence_of :body # , :if => [Proc.new { |u| u.step == 2 }, :something?]
        end
      end
      
      validation_scope :if => Proc.new { |u| u.step == 3 } do |v|
        v.validates_inclusion_of :outstanding_finance, :in => [true, false], :if => Proc.new { |u| u.finance == true }
        # Duplicate keys are turned into arrays
        # :if => [Proc.new { |u| u.finance == true }, Proc.new { |u| i.step == 3 }]
        
        v.validate do # v.validate :if => Proc.new { |u| u.step == 3 }
          errors.add(:weight, "Must be greater than 0") unless !@weight.nil? && @weight > 0
        end
      end
    end

The options passed into the validation_scope method will usually be either :if or :unless, but any are accepted and they are passed onto the individual validators.
    
# Installation

Add the gem to your Gemfile

    gem "validation-scopes"

It will be included into ActiveRecord::Base if it is defined, if not use `include ValidationScopes` on any ActiveModel object.