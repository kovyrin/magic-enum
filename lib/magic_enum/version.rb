# Version info
module MagicEnum
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 3
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
