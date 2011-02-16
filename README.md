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

The options passed into the validation_scope method will usually be either :if or :unless, but any are accepted and they are passed onto the individual validators.
    
# Installation

Add the gem to your Gemfile

    gem "validation-scopes"

It will be included into ActiveRecord::Base if it is defined, if not use `include ValidationScopes` on any ActiveModel object.

# ActiveSupport alternative

ActiveSupport has an OptionMerger class for achieving the same thing generically and can be used anywhere (I noticed this after I wrote this gem). The only downside is that it will not merge option values into an array. In the example below the :if Proc on the `validates_inclusion_of` line would take precedence over the one defined on the `with_options` line. See the source code for [with_options](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/object/with_options.rb) for more details.

    class Car < ActiveRecord::Base
      with_options :if => Proc.new { |u| u.step == 2 } do |v|
        v.validates_presence_of :variant
        v.validates_presence_of :body
      end
      
      with_options :if => Proc.new { |u| i.step == 3 } do |v|
        v.validates_inclusion_of :outstanding_finance, :in => [true, false], :if => Proc.new { |u| u.finance == true }
      end
    end