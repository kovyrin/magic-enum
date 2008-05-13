require File.dirname(__FILE__) + '/lib/magic_enum'

ActiveRecord::Base.send(:include, MagicEnum)
