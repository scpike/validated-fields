# ValidatedFields

**This plugin is at an early stage of development. Don't use it yet. Examples below are mostly just a proof of concept.**

ValidatedFields is a set of helpers for unobtrusive frontend validations using HTML5 attributes, Rails 3 validators and JavaScript.

It overrides the default rails form helpers and uses Validator reflection to gather validation rules declared in model classes.

## Usage

Here's a basic example, just to give you an idea what the plugin does:

    class User < ActiveRecord::Base
      validates :name, :presence => true, :message => 'Name is required'
    end
    
    <%= form_for @user do |f| %>
      <%= f.text_field :name %>
    <% end %>
    
The text field would looke like this:

    <input class="validated" data-required-error-msg="Name is required" id="user_name" name="user[name]" required="required" type="text" />
    
Once we have those custom attributes, we can easily validate the field using JavaScript (jQuery example):

    $('.validated').blur(function() {
        if ($(this).attr('required') && $(this).attr('value') == '') {
            alert($(this).attr('data-required-error-msg')); // alerts are evil, don't use them in your code ;)
        }
    });

### Installation

Add the following line to your Gemfile:

    gem 'validated_fields', :git => 'http://github.com/pch/validated-fields.git'

### Standard validation

By default validated_field supports the following built-in validators:

* presence
* format
* length

### Custom validator classes 

If you'd like use your own validators, you'll need to override the `setup_validation_options` method:

    class EmailValidator < ActiveModel::EachValidator
      EMAIL_REGEX = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    
      def validate_each(record, attribute, value)
        record.errors[attribute] << (options[:message] || "invalid email format") unless value =~ EMAIL_REGEX
      end
    end
    
    class User
      validates :email, :email => true
    end
    
    module UsersHelper
      protected
        def setup_validation_options(object_name, attribute, options)
          options = super(object_name, attribute, options)
          options = check_email(object_name, attribute, options)
          options
        end
        
        def check_email(object_name, attribute, options)
          validator = find_validator(object_name, attribute, ActiveModel::Validations::PresenceValidator)

          options[:pattern] = EmailValidator.EMAIL_REGEX.inspect
          options["data-email-error-msg"] = validator.options[:message] if validator.options[:message].present?
          options
        end
    end

### Disabling validation

In order to disable frontend validation for a given field, add :validate => false option:

    <%= f.text_field :name, :validate => false %>

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

### Credits

- Piotr Chmolowski (<http://github.com/pch>)
