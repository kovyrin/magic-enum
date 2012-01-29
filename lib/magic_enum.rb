module MagicEnum
  def self.append_features(base) #:nodoc:
    super
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Method used to define ENUM attributes in your model. Examples:
    #
    #   Statuses = {
    #     :draft => 0,
    #     :published => 1,
    #     :approved => 2
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
    #   Statuses = {
    #     :unknown => 0,
    #     :draft => 1,
    #     :published => 2,
    #     :approved => 3
    #   }
    #   define_enum :status, :default => 1, :raise_on_invalid => true, :simple_accessors => true
    #
    # This example is identical to:
    #
    #   Statuses = {
    #     :unknown => 0,
    #     :draft => 1,
    #     :published => 2,
    #     :approved => 3
    #   }
    #   StatusesInverted = Statuses.invert
    #
    #   def status
    #     return StatusesInverted[self[:status].to_i] || StatusesInverted[1]
    #   end
    #
    #   def status=(value)
    #     raise ArgumentError, "Invalid value \"#{value}\" for :status attribute of the #{self.class} model" if Statuses[value].nil?
    #     self[:status] = Statuses[value]
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
      default_opts = {  :raise_on_invalid => false,
                        :simple_accessors => false,
                        :named_scopes => false,
                        :scope_extensions => false
                        }
      opts = default_opts.merge(opts)
      name = name.to_sym

      # bug in Rails 1.2.2
      opts[:enum] = name.to_s.pluralize.classify.pluralize unless opts[:enum]
      enum = opts[:enum]
      enum_inverted = "#{enum}Inverted"

      opts[:default] = const_get(enum).values.sort do |a, b|
        if a.nil? and b.nil?
          0
        elsif a.nil?
          -1
        elsif b.nil?
          1
        else
          a <=> b
        end
      end.first unless opts[:default]

      const_set(enum_inverted, const_get(enum).invert)

      define_method name do
        self.class.const_get(enum_inverted)[self[name]] || self.class.const_get(enum_inverted)[opts[:default]]
      end

      define_method "#{name}_name" do
        send(name).to_s
      end

      define_method "#{name}=" do |value|
        value = value.to_sym if value.is_a?(String)
        raise ArgumentError, "Invalid value \"#{value}\" for :#{name} attribute of the #{self.class} model" if opts[:raise_on_invalid] and self.class.const_get(enum)[value].nil?
        if value.is_a?(Integer)
          self[name] = value
        else
          self[name] = self.class.const_get(enum)[value] || opts[:default]
        end
      end

      if opts[:simple_accessors]
        const_get(enum).keys.each do |key|
          define_method "#{key}?" do
            send(name) == key
          end
        end
      end

      # Create named scopes for each enum value
      if opts[:named_scopes]
        const_get(enum).keys.each do |key|
          named_scope key.to_s.pluralize.to_sym, :conditions => ["#{name} = ?", const_get(enum)[key]] do
            opts[:scope_extensions].each do |ext_name, ext_block|
              define_method ext_name, ext_block
            end if opts[:scope_extensions] and opts[:scope_extensions].is_a?(Hash)
          end
        end
        named_scope "of_#{name}".to_sym, lambda { |t| { :conditions => ["#{name} = ?", const_get(enum)[t]] } } do
          opts[:scope_extensions].each do |ext_name, ext_block|
            define_method ext_name, ext_block
          end if opts[:scope_extensions] and opts[:scope_extensions].is_a?(Hash)
        end
      end

    end
  end
end
