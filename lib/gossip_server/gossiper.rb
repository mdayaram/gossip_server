require 'http'

module GossipServer
  class Gossiper
    attr_reader :my_id
    attr_reader :peers
    attr_reader :world_state

    attr_reader :messages_cache
    attr_reader :messages_seen

    def initialize(id:, seed_id:)
      @my_id = id.to_s
      @peers = Set.new
      @messages_seen = Set.new
      @messages_cache = []
      @world_state = {}

      peers << seed_id.to_s if seed_id
    end

    def peers_handler(client_id:)
      # Add this client to our peers set since it's a new node in our network.
      peers << client_id

      # return back our peers for them.
      peers.to_a
    end

    # Messages is an array, each element a hash of the following:
    #   uuid:       string
    #   client_id:  string
    #   version:    int
    #   ttl:        int
    #   payload:    string
    def gossip_handler(messages)
      # Ignore messages we've seen or have had their TTL expire.
      messages = messages.select { |m| m[:ttl] > 0 && !messages_seen.include?(m[:uuid]) }

      # Update our world view
      messages.each do |m|
        update_world_state(
          client_id: m[:client_id],
          version: m[:version],
          payload: m[:payload]
        )
      end

      # Cache these messages
      messages.each do |m|
        m[:ttl] -= 1
        messages_cache << m
        messages_seen << m[:uuid]
      end

      "OK"
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

    def gossip_peers!
      peers_to_gossip = [peers.to_a.sample].compact # Only pick one for now.
      return if peers_to_gossip.empty?

      peers_to_gossip.each do |p|
        res = HTTP.post("#{peer_host(p)}/gossip", json: message_cache).to_s

        # If this peer did not like our gossip, remove it from our network
        peers.delete(p) if res != "OK"
      end
    end

    private

    def peer_host(peer_id)
      "http://localhost:#{peer_id}"
    end

    def update_world_state(client_id:, version:, payload:)
      if world_state[client_id].nil?
        world_state[client_id] = {version: version, payload: payload}
      elsif world_state[client_id][:version] < version
        world_state[client_id] = {version: version, payload: payload}
      else
        world_state[client_id] # Keep current state, version was older.
      end
    end
  end
end
