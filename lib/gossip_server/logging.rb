module GossipServer
  module Logging
    @@debug = false

    def self.set_debug(v)
      @@debug = v
    end

    def log(*args)
      puts args.join(" ")
    end

    def debug(*args)
      puts args.join(" ") if @@debug
    end
  end
end
