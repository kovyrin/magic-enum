# Version info
module MagicEnum
  module Version
    MAJOR = 0
    MINOR = 9
    PATCH = 0
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
