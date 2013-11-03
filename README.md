# MagicEnum

MagicEnum is a simple ActiveRecord plugin that makes it easier to maintain ENUM-like attributes in your models.

Examples:

    STATUSES = {
      :draft     => 0,
      :published => 1,
      :approved  => 2,
    }
    define_enum :status

## Please note: breaking changes in 1.0.0

Before version 1.0.0, the hash with ENUM values was camel-cased. We decided to change it to more rubyish upper-cased constant names. If you're upgrading from pre-1.0.0, please
change you constants accordingly. Examples:

    Statuses => STATUSES
    SimpleStatuses => SIMPLE_STATUSES

Name of inverted hash was changed as well:

    StatusesInverted => STATUSES_INVERTED
    SimpleStatusesInverted => SIMPLE_STATUSES_INVERTED

## How to Use

Before using `define_enum`, you should define constant with ENUM options.
Constant name would be pluralized enum attribute name (e.g. `SIMPLE_STATUSES`
`simple_status` enum). Additional constant named like `YOUR_ENUM_INVERTED`
would be created automatically and would contain inverted hash.

**Please note**: `nil` and `0` are not the same values!

You could specify additional options:

* `:default` — value which will be used when current state of ENUM attribute is invalid or wrong value received. If it has not been specified, min value of the ENUM would be used. Could be specified as a symbol;
* `:raise_on_invalid` — if `true` an exception would be raised on invalid enum value received. If it is `false`, default value would be used instead of wrong one;
* `:simple_accessors` — if `true`, additional methods for each ENUM value would be defined in form `value?`. Methods returns `true` when ENUM attribute has corresponding value;
* `:enum` — string with name of the ENUM hash;
* `:named_scopes` — whether to generate named scopes for values of ENUM (pluralized key names). In addition to per-key named scope, `of_name` scope will be generated, which accepts a symbol corresponding to ENUM value.

Look the following example:

    STATUSES = {
      :unknown   => 0,
      :draft     => 1,
      :published => 2,
      :approved  => 3,
    }
    define_enum :status, :default => 1, :raise_on_invalid => true, :simple_accessors => true

This example is identical to:

    STATUSES = {
      :unknown   => 0,
      :draft     => 1,
      :published => 2,
      :approved  => 3,
    }
    STATUSES_INVERTED = STATUSES.invert

    def self.status_value(status)
      STATUSES[status]
    end

    def self.status_by_value(value)
      STATUSES_INVERTED[value]
    end

    def status
      self.class.status_by_value(self[:status]) || self.class.status_by_value(1)
    end

    def status=(value)
      raise ArgumentError, "Invalid value \"#{value}\" for :status attribute of the #{self.class} model" unless STATUSES.key?(value)
      self[:status] = STATUSES[value]
    end

    def unknown?
      status == :unknown
    end

    def draft?
      status == :draft
    end

    def published?
      status == :published
    end

    def approved?
      status == :approved
    end

## Who are the authors?

This plugin was originally developed for [BestTechVideos project](http://www.bestechvideos.com) by [Dmytro Shteflyuk](http://kpumuk.info)
and later cleaned up in Scribd repository and released to the public by [Oleksiy Kovyrin](http://kovyrin.net). All the code in this package is released under
the MIT license. For more details, see the LICENSE file.
