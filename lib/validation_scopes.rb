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
      @_handled_by_with = false
    end
    
    def validates_with(*args, &block)
      if @_in_validation_scope
        merge_args(args)
        @_handled_by_with = true
      end
      super(*args, &block)
    end
    
    def validate(*args, &block)
      if @_in_validation_scope & !@_handled_by_with
        merge_args(args)
      end
      super(*args, &block)
    end
    
    protected
    
    def merge_args(args)
      if args.empty?
        args << @_validation_scope_options.dup
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
  end
end

ActiveRecord::Base.send(:include, ValidationScopes) if defined?(ActiveRecord)