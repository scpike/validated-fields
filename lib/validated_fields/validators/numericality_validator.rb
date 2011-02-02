module ValidatedFields
  module Validators
    #
    # Sets options for ActiveModel::Validations::NumericalityValidator
    #
    module NumericalityValidator

      def self.prepare_options(validator, options)
        voptions = validator.options
        precision = 0.000000001
        # FIXME: will work properly only for integers
        options[:min] = voptions[:greater_than].to_f + precision if voptions[:greater_than].present?
        options[:max] = voptions[:less_than].to_f    - precision if voptions[:less_than].present?
        
        options[:min] = voptions[:greater_than_or_equal_to].to_f if voptions[:greater_than_or_equal_to].present?
        options[:max] = voptions[:less_than_or_equal_to].to_f  if voptions[:less_than_or_equal_to].present?
        
        options[:only_integer] = voptions[:only_integer]
        
        options['data-error-numericality'] = voptions[:message] || "Invalid number"
        options
      end
    end
    
  end
end
