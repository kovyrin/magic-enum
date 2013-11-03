# Version info
module MagicEnum
  module Version
    MAJOR = 1
    MINOR = 0
    PATCH = 0
    BUILD = 'beta1'

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
