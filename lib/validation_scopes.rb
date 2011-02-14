require 'active_support/concern'
require 'active_model'

module ValidationScopes
  extend ActiveSupport::Concern
  
  module ClassMethods

    def validation_scope(options, &block)
      @_in_validation_scope = true
      @_validation_scope_options = options
      block.call
      @_validation_scope_options = nil
      @_in_validation_scope = false
    end
    
    def validate(*args, &block)
      if @_in_validation_scope
        if args.empty?
          args = [@_validation_scope_options.dup]
        elsif args.last.is_a?(Hash) && args.last.extractable_options?
          options = args.extract_options!
          options = options.dup
          @_validation_scope_options.each_key do |key|
            if options[key].nil?
              options[key] = @_validation_scope_options[key]
            else
              options[key] = Array.wrap(options[key])
              options[key] << @_validation_scope_options[key]
            end
          end
          args << options
        end
      end
      super(*args, &block)
    end
  end
end

ActiveRecord::Base.send(:include, ValidationScopes) if defined?(ActiveRecord)