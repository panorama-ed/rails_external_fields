require "external_fields/version"

# This concern maintains the illusion that a given object has specified
# attributes, when those attributes are in fact attached to an associated
# object. This is particularly useful for different classes within a single-
# table inheritance table to have access to separate fields in class-specific
# associations.

module ExternalFields
  extend ActiveSupport::Concern

  included do
    class_attribute :_external_field_associations

    # Provides a getter and setter for the given attribute on the associated
    # object. We provide either normal or underscored getters and setters, the
    # latter allowing the defining class to use alias_method to override
    # behavior while still accessing these underlying implementations.
    #
    # @param attrs [Array<Symbol>] list of external fields
    # @param assoc [Symbol] name of the association
    # @param class_name [String] name of the associated class
    # @param underscore [Boolean] underscored accessor created if true
    def self.external_field(*attrs, assoc, class_name: nil, underscore: false)
      self._external_field_associations ||= []

      attrs.each do |attr|
        # Store the original association method for use in the overwritten one.
        original_method = instance_method(assoc)

        # First, we define an accessor for the associated object.
        # Note we ensure that we only define the accessor once. Further, if
        # `use_original` is true, we use the original Rails association
        # accessor, which will not build a new object. Otherwise, we build a new
        # object if one does not exist already.
        unless self._external_field_associations.include? assoc
          define_method assoc do |use_original: false|
            if use_original
              # Call original overwritten method
              original_method.bind(self).call
            else
              # Try calling the original method to see if we get a result.
              existing_value = original_method.bind(self).call

              # Use existing value if one is there.
              if existing_value
                existing_value
              else # Otherwise, build a new object.
                # Find the class of the object we need to build.
                klass = class_name.try(:constantize) ||
                        self.class.reflect_on_association(assoc).klass

                send("#{assoc}=", klass.new)
              end
            end
          end
        end

        # Now, define the getters for the specific attribute.
        define_method(underscore ? "_#{attr}" : attr) do
          send(assoc).try(attr)
        end

        # Now, define the setters for the specific attribute.
        define_method(underscore ? "_#{attr}=" : "#{attr}=") do |new_attr|
          send(assoc).send("#{attr}=", new_attr)
        end

        # Add the association name to the set of external field associations.
        # This allows other parts of the codebase to quickly see all of the
        # associations a class has that store external fields. This array stores
        # association name symbols, like: [:address, :extra_data]
        # Note that a Set could be used here but an Array was chosen for
        # familiarity since the size of the array will be relatively small.
        unless self._external_field_associations.include? assoc
          # We need to duplicate the array because a subclass of a model with
          # this mixin would otherwise modify its parent class' array, since the
          # << operator works in-place.
          self._external_field_associations =
            self._external_field_associations.dup

          self._external_field_associations << assoc
        end
      end
    end
  end
end
