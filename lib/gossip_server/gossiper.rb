module GossipServer
  class Gossiper
    attr_reader :port, :seed

    def initialize(port:, seed:)
      @port = port
      @seed = seed
    end

    def peers(client:)
      client
    end

    def gossip(client:, body:)
      body
    end
  end
end
