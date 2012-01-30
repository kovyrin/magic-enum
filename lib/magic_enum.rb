require 'magic_enum/version'
require 'magic_enum/class_methods'

ActiveRecord::Base.extend(MagicEnum::ClassMethods)
