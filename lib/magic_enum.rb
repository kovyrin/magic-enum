require 'magic_enum/version'
require 'magic_enum/class_methods'

ActiveModel::Base.extend(MagicEnum::ClassMethods)
