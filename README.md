# Validation Scopes

Validation Scopes allows you to group validations together that share the same conditions. It depends on ActiveModel. Example:

    class Car < ActiveRecord::Base
      validation_scope :if => Proc.new { |u| u.step == 2 } do
        # All validations here get their options merged with the options passed in above
        validates_presence_of :variant
        validates_presence_of :body
      end
      
      validation_scope :if => Proc.new { |u| i.step == 3 } do
        validates_inclusion_of :outstanding_finance, :in => [true, false], :if => Proc.new { |u| u.finance == true }
      end
    end
    
# Installation

Add the gem to your Gemfile

    gem "validation-scopes"

It will be included into ActiveRecord::Base if it is defined, if not use `include ValidationScopes` on any ActiveModel object.