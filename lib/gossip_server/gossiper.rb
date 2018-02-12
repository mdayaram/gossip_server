module GossipServer
  class Gossiper
    attr_reader :port, :seed
    attr_reader :peers

    def initialize(port:, seed:)
      @port = port
      @seed = seed
      @peers = Set.new

      if seed > 0
        peers << seed
      end
    end

    def peers_handler(client:)
      peers_list = peers.to_a

      # Add this client to our peers set since it's a new node in our network.
      peers << client

      # return back our peers for them.
      peers_list
    end

    def gossip_handler(client:, body:)
      body
    end
  end
end
