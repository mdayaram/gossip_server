module GossipServer
  class Gossiper
    attr_reader :my_id, :seed_id
    attr_reader :peers

    def initialize(id:, seed_id:)
      @my_id = id
      @seed_id = seed_id
      @peers = Set.new

      peers << seed_id if seed_id
    end

    def peers_handler(client_id:)
      # Add this client to our peers set since it's a new node in our network.
      peers << client_id

      # return back our peers for them.
      peers.to_a
    end

    def gossip_handler(msg = {})
      msg
    end
  end
end
