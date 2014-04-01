module MagicEnum
  module ClassMethods
    # Method used to define ENUM attributes in your model. Examples:
    #
    #   STATUSES = {
    #     :draft     => 0,
    #     :published => 1,
    #     :approved  => 2,
    #   }
    #   define_enum :status
    #
    # Before using <tt>define_enum</tt>, you should define constant with ENUM options.
    # Constant name would be pluralized enum attribute name. Additional constant named
    # like <tt>YourEnumInverted</tt> would be created automatically and would contain
    # inverted hash.
    #
    # <b>Please note</b>: <tt>nil</tt> and <tt>0</tt> are not the same values!
    #
    # You could specify additional options:
    #
    # * <tt>:default</tt> - value which will be used when current state of ENUM attribute is
    #   invalid or wrong value received. If it has not been specified, min value of the ENUM would
    #   be used.
    # * <tt>:raise_on_invalid</tt> - if <tt>true</tt> an exception would be raised on invalid
    #   enum value received. If it is <tt>false</tt>, default value would be used instead of
    #   wrong one.
    # * <tt>:simple_accessors</tt> - if <tt>true</tt>, additional methods for each ENUM value
    #   would be defined in form <tt>value?</tt>. Methods returns <tt>true</tt> when
    #   ENUM attribute has corresponding value.
    # * <tt>:enum</tt> - string with name of the ENUM hash.
    #
    # Look the following example:
    #
    #   STATUSES = {
    #     :unknown   => 0,
    #     :draft     => 1,
    #     :published => 2,
    #     :approved  => 3,
    #   }
    #   define_enum :status, :default => 1, :raise_on_invalid => true, :simple_accessors => true
    #
    # This example is identical to:
    #
    #   STATUSES = {
    #     :unknown   => 0,
    #     :draft     => 1,
    #     :published => 2,
    #     :approved  => 3,
    #   }
    #   STATUSES_INVERTED = STATUSES.invert
    #
    #   def self.status_value(status)
    #     STATUSES[status]
    #   end
    #
    #   def self.status_by_value(value)
    #     STATUSES_INVERTED[value]
    #   end
    #
    #   def status
    #     self.class.status_by_value(self[:status]) || self.class.status_by_value(1)
    #   end
    #
    #   def status=(value)
    #     raise ArgumentError, "Invalid value \"#{value}\" for :status attribute of the #{self.class} model" unless STATUSES.key?(value)
    #     self[:status] = STATUSES[value]
    #   end
    #
    #   def unknown?
    #     status == :unknown
    #   end
    #
    #   def draft?
    #     status == :draft
    #   end
    #
    #   def published?
    #     status == :published
    #   end
    #
    #   def approved?
    #     status == :approved
    #   end
    #
    def define_enum(name, opts = {})
      opts = opts.reverse_merge({
        :raise_on_invalid => false,
        :simple_accessors => false,
        :named_scopes     => false,
        :scope_extensions => false,
      })
      name = name.to_sym

      opts[:enum] ||= name.to_s.pluralize.upcase
      enum = opts[:enum]
      enum_inverted = "#{enum}_INVERTED"
      enum_value = const_get(enum)

      if opts.key?(:default)
        opts[:default] = enum_value[opts[:default]] if opts[:default].is_a?(Symbol)
      else
        opts[:default] = enum_value.values.sort do |a, b|
          if a.nil? and b.nil?
            0
          elsif a.nil?
            -1
          elsif b.nil?
            1
          else
            a <=> b
          end
        end.first
      end

      enum_inverted_value = enum_value.invert
      if !const_defined?(enum_inverted)
        const_set(enum_inverted, enum_value.invert)
      elsif const_get(enum_inverted) != enum_inverted_value
        raise ArgumentError, "Inverted enum constant \"#{enum_inverted}\" is already defined and contains wrong values"
      end

      class_eval <<-RUBY
        def self.#{name}_value(name)
          name = name.to_sym if name.is_a?(String)
          #{enum}[name]
        end

        def self.#{name}_by_value(value)
          #{enum_inverted}[value]
        end

        def #{name}
          self.class.#{name}_by_value(self[:#{name}]) || self.class.#{name}_by_value(#{opts[:default].inspect})
        end

        def #{name}_name
          self.#{name}.to_s
        end

        def #{name}_value
          self[:#{name}] || #{opts[:default].inspect}
        end

        def #{name}=(value)
          value = value.to_sym if value.is_a?(String)
          if value.is_a?(Integer)
            raise ArgumentError, "Invalid value \\"\#{value}\\" for :#{name} attribute of the #{self.name} model" if #{!!opts[:raise_on_invalid]} and !#{enum_inverted}.key?(value)
            self[:#{name}] = value
          else
            raise ArgumentError, "Invalid value \\"\#{value}\\" for :#{name} attribute of the #{self.name} model" if #{!!opts[:raise_on_invalid]} and !#{enum}.key?(value)
            self[:#{name}] = self.class.#{name}_value(value) || #{opts[:default].inspect}
          end
        end
      RUBY

      if opts[:simple_accessors]
        enum_value.keys.each do |key|
          class_eval "def #{key}?() #{name} == :#{key} end"
        end
      end

      # Create named scopes for each enum value
      if opts[:named_scopes]
        scope_definition_method = respond_to?(:named_scope) ? :named_scope : :scope

        enum_value.keys.each do |key|
          define_enum_scope(enum, key.to_s.pluralize, name, key, opts[:scope_extensions])
        end

        define_enum_scope(enum, "of_#{name}", name, nil, opts[:scope_extensions])
      end

    end

    private

    def define_enum_scope(enum, scope_name, name, key, scope_extensions)
      if respond_to?(:named_scope)
        # Rails 2.2 - 2.3

        where_clause = if key
          { :conditions => { name => const_get(enum)[key] } }
        else
          lambda { |t| { :conditions => { name => const_get(enum)[t] } } }
        end

        named_scope scope_name.to_sym, where_clause do
          scope_extensions.each do |ext_name, ext_block|
            define_method ext_name, ext_block
          end if Hash === scope_extensions
        end
      else
        # Rails 3+

        where_clause = if key
          lambda { where(name => const_get(enum)[key]) }
        else
          lambda { |t| where(name => const_get(enum)[t]) }
        end

        scope scope_name.to_sym, where_clause do
          scope_extensions.each do |ext_name, ext_block|
            define_method ext_name, ext_block
          end if Hash === scope_extensions
        end
      end
    end
  end
end
