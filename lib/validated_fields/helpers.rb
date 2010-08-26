
module ValidatedFields  
  module Helpers
    def self.included(base)
      base.class_eval do
        include ValidatedFields::Validators::PresenceValidator
        include ValidatedFields::Validators::FormatValidator
        include ValidatedFields::Validators::LengthValidator
        include ValidatedFields::Validators::NumericalityValidator
      end
    end
    
    def check_box(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
      options = setup_validation_options(object_name, method, options)
      super(object_name, method, options, checked_value, unchecked_value)
    end
    
    def password_field(object_name, method, options = {})
      options = setup_validation_options(object_name, method, options)
      super(object_name, method, options)
    end
    
    def text_area(object_name, method, options = {})
      options = setup_validation_options(object_name, method, options)
      super(object_name, method, options)
    end
    
    def text_field(object_name, method, options = {})
      options = setup_validation_options(object_name, method, options)
      super(object_name, method, options)
    end
    
    protected
      
      def setup_validation_options(object_name, attribute, options)
        if options[:validate].nil? || options[:validate] != true
          options.delete(:validate) unless options[:validate].nil?
          return options
        end
        
        validations     = 0  # counter
        validator_names = []
        
        validators = validators_for(object_name, attribute)
        validators.each do |validator|
          next if skip_validation?(options[:object], validator.options)
          
          # if validator class is namespaced, extract class name only:
          validator_name = validator.class.to_s.split("::").last
          
          # check if validator has a helper implemented in ValidatedFields::Validators namespace:
          if ValidatedFields::Validators.const_defined?(validator_name)
            options = eval("ValidatedFields::Validators::#{validator_name}").prepare_options(validator, options)
            validator_names.push(validator_name.gsub(/Validator/, '').downcase) # e.g. PresenceValidator => presence
            
            validations += 1
          end
        end
        
        if validations > 0
          options[:class]           = options[:class].present? ? options[:class] + " validated" : "validated"
          options['data-validates'] = validator_names.uniq.join(' ') # list of all validators
        end
        
        options.delete(:validate)
        options
      end
      
      # Returns the list of all validators assigned to attribute
      def validators_for(object_name, attribute)
        object_name.to_s.classify.constantize.validators_on(attribute)
      end
      
      def skip_validation?(object, voptions)
        if voptions[:if].present?
          return true if voptions[:if].is_a?(Proc)   && voptions[:if].call(object) == false
          return true if voptions[:if].is_a?(Symbol) && object.send(voptions[:if]) == false
        end
        
        if voptions[:unless].present?
          return true if voptions[:unless].is_a?(Proc)   && voptions[:unless].call(object) == true
          return true if voptions[:unless].is_a?(Symbol) && object.send(voptions[:unless]) == true
        end
        
        false
      end
  end
end
