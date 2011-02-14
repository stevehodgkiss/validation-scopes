# Validation Scopes

Validation Scopes allows you to group validations together that share the same conditions. It depends on ActiveModel. Example:

    class Car < ActiveRecord::Base
      validation_scope :if => Proc.new { |u| u.step == 2 } do
        validates_presence_of :variant
        validates_presence_of :body
      end
      
      validation_scope :if => Proc.new { |u| i.step == 3 } do
        validates_inclusion_of :outstanding_finance, :in => [true, false], :if => Proc.new { |u| u.finance == true }
        # Duplicate keys are turned into arrays
        # In this case InclusionValidator would get an array containing both Procs in the :if attribute
        
        validate do
          errors.add(:weight, "Must be greater than 0") unless !@weight.nil? && @weight > 0
        end
      end
    end
    
# Installation

Add the gem to your Gemfile

    gem "validation-scopes"

It will be included into ActiveRecord::Base if it is defined, if not use `include ValidationScopes` on any ActiveModel object.