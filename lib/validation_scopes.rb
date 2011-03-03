require 'active_support/concern'
require 'active_model'

module ValidationScopes
  extend ActiveSupport::Concern
  
  module ClassMethods

    def validation_scope(options, &block)
      @_nested_level_count ||= 0
      @_validation_scope_options ||= {}
      parent_options = @_validation_scope_options[@_nested_level_count]
      @_nested_level_count += 1
      @_validation_scope_options[@_nested_level_count] = parent_options.nil? ? options : merge_options(parent_options.dup, options)
      block.call
      @_nested_level_count -= 1
      @_handled_by_with = false
    end
    
    def validates_with(*args, &block)
      if in_validation_scope?
        merge_args(args)
        @_handled_by_with = true
      end
      super(*args, &block)
    end
    
    def validate(*args, &block)
      if in_validation_scope? & !@_handled_by_with
        merge_args(args)
      end
      @_handled_by_with = false
      super(*args, &block)
    end
    
    private
    
    def in_validation_scope?
      !@_nested_level_count.nil? && @_nested_level_count > 0
    end
    
    def merge_args(args)
      if args.empty?
        args << @_validation_scope_options[@_nested_level_count].dup
      elsif args.last.is_a?(Hash) && args.last.extractable_options?
        options = args.extract_options!
        options = options.dup
        merge_options(options, @_validation_scope_options[@_nested_level_count])
        args << options
      end
    end
    
    def merge_options(options_a, options_b)
      return options_b if options_a.nil?
      options_a = options_a
      options_b.each_key do |key|
        if options_a[key].nil?
          options_a[key] = options_b[key]
        else
          options_a[key] = Array.wrap(options_a[key]) unless options_a[key].is_a?(Array)
          options_a[key] << options_b[key]
        end
      end
      options_a
    end
  end
end

ActiveRecord::Base.send(:include, ValidationScopes) if defined?(ActiveRecord)