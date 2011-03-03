require 'active_support/concern'

module ValidationScopes
  extend ActiveSupport::Concern
  
  class OptionMerger
    instance_methods.each do |method|
      undef_method(method) if method !~ /^(__|instance_eval|class|object_id)/
    end

    def initialize(context, options)
      @context, @options = context, options
    end
    
    def validation_scope(options)
      yield OptionMerger.new(@context, merge_options(@options, options))
    end

    private
      def method_missing(method, *arguments, &block)
        arguments << if arguments.last.respond_to?(:to_hash)
          merge_options(@options, arguments.pop)
        else
          @options.dup
        end
        @context.__send__(method, *arguments, &block)
      end
      
      def merge_options(options_b, options_a)
        return options_b.dup if options_a.nil?
        options_a = options_a.dup
        options_b.each_pair do |key, value|
          if options_a[key].nil?
            options_a[key] = value
          else
            options_a[key] = Array.wrap(options_a[key]) unless options_a[key].is_a?(Array)
            if value.is_a?(Array)
              value.each do |v|
                options_a[key] << v
              end
            else
              options_a[key] << value
            end
          end
        end
        options_a
      end
  end
  
  module ClassMethods

    def validation_scope(options, &block)
      raise "Deprecated. See readme for new usage. https://github.com/stevehodgkiss/validation-scopes" if block.arity == 0
      yield OptionMerger.new(self, options)
    end
    
  end
end

ActiveRecord::Base.send(:include, ValidationScopes) if defined?(ActiveRecord)