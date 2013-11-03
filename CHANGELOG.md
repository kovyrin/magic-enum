## 1.0.0 (in development)

Features:

  - Added "enum_value" (returns value) instance method in addition to "enum_name" (returns stringified enum key)
  - Added class methods "enum_value" (returns value by key) and "enum_by_value" (returns key by value)
  - Performance improvement: use `class_eval` with string instead of blocks

Bugfixes:

  - Fixed const naming: use `SIMPLE_STATUSES` and `SIMPLE_STATUSES_INVERTED` instead of `SimpleStatuses` and `SimpleStatusesInverted`

## 0.9.0 (August 8, 2013)

Bugfixes:

  - Allow `nil` values
  - Updated specs to RSpec 1.2 syntax

Features:

  - Rails 4.0.0 support

## 0.0.3 (January 29, 2012)

Features:

  - Files re-organization

## 0.0.2 (January 29, 2012)

Features:

  - Rails < 3.3 support

## 0.0.1 (January 29, 2012)

Features:

  - First gem version

## 0.0.0 (January 16, 2009)

Features:

  - Setter method symbolizes strings

Bugfixes:

  - Added tests for named scopes

## 0.0.0 (September 21, 2008)

Features:

  - Added a special named scope "of_name", which accepts symbol
  - Added scope extensions

## 0.0.0 (September 1, 2008)

Features:

  - Setter method accepts integer values in addition to symbols

## 0.0.0 (August 30, 2008)

Features:

  - Added support of named scopes

## 0.0.0 (August 30, 2008)

Features:

  - Added support of named scopes

## 0.0.0 (May 12, 2008)

Features:

  - Basic ENUM functionality
