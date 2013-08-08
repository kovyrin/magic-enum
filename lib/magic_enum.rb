require 'magic_enum/version'
require 'magic_enum/class_methods'
require 'active_record'

ActiveRecord::Base.extend(MagicEnum::ClassMethods)
