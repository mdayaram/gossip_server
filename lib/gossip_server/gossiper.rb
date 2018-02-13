require 'http'

module GossipServer
  class Gossiper
    attr_reader :my_id
    attr_reader :peers

    def initialize(id:, seed_id:)
      @my_id = id.to_s
      @peers = Set.new

      peers << seed_id.to_s if seed_id
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

    def fetch_peers!
      return false if peers.empty?

      chosen_peer = peers.to_a.sample
      res = HTTP.get("#{peer_host(chosen_peer)}/peers/#{my_id}").to_s
      more_peers = JSON.parse(res)

      more_peers.each do |p|
        next if p == my_id
        peers << p
      end
    end

    private

    def peer_host(peer_id)
      "http://localhost:#{peer_id}"
    end
  end
end
