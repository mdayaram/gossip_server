require 'http'
require 'securerandom'

module GossipServer
  class Gossiper
    include Logging

    attr_reader :my_id
    attr_reader :infection_factor
    attr_reader :default_ttl
    attr_reader :peers
    attr_reader :world_state

    attr_reader :messages_cache
    attr_reader :messages_seen

    def initialize(id:, seed_id:, infection_factor:, default_ttl:, world_state:)
      @my_id = id.to_s
      @infection_factor = infection_factor > 0 ? infection_factor : 2
      @default_ttl = default_ttl > 0 ? default_ttl : 2
      @peers = Set.new
      @messages_seen = Set.new
      @messages_cache = []
      @world_state = world_state

      peers << seed_id.to_s if !seed_id.nil? && !seed_id.empty?
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
    def gossip_handler(client_id:, messages:)
      return { status: "ERROR" } if client_id.nil? || client_id.empty?

      # Add this gossiper to our peers group.
      peers << client_id

      # Update our world view
      (messages || []).each do |m|
        absorb_message(m)
      end

      { status: "OK" }
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
      peers_to_gossip = peers.to_a.sample(infection_factor)
      return if peers_to_gossip.empty?

      peers_to_gossip.each do |p|
        gossip_peer!(p)
      end
    end

    def gossip_peer!(peer_id)
      raw_res = HTTP.post(
        "#{peer_host(peer_id)}/gossip",
        json: {client_id: my_id, messages: messages_cache}
      ).to_s

      res = JSON.parse(raw_res, symbolize_names: true)

      # If this peer did not like our gossip, remove it from our network
      if res[:status] != "OK"
        log "Removing peer #{peer_id} because response was: #{res}"
        peers.delete(peer_id)
      end
    rescue HTTP::Error
      log "Removing peer #{peer_id} because could not gossip to them."
      peers.delete(peer_id)
    end

    def add_payload(new_payload)
      message = {
        uuid: SecureRandom.uuid,
        payload: new_payload,
        ttl: default_ttl,
        client_id: my_id
      }

      absorb_message(message)
    end

    def to_s
      ["My State: #{world_state.my_s}",
       "Peers: #{peers.to_a.join(" ")}",
       "World State:",
       world_state.to_s,
       "",
       (["Seen Messages:"] + messages_seen.to_a).join("\n\t"),
       (["Message Cache (most recent on top):"] + messages_cache.reverse.map do |m|
         message_to_s(m)
       end).join("\n\t")
      ].join("\n\n")
    end

    private

    def absorb_message(uuid:, client_id:, payload:, ttl:)
      debug message_to_s(
        uuid: uuid,
        client_id: client_id,
        payload: payload,
        ttl: ttl
      ) if client_id == my_id

      # Ignore messages we've seen or have had their TTL expire.
      return if ttl <= 0 || messages_seen.include?(uuid)

      # Update our world view
      world_state.update_world_state(client_id: client_id, payload: payload)

      # Cache these messages
      messages_seen << uuid
      messages_cache << {
        uuid: uuid,
        client_id: client_id,
        payload: payload,
        ttl: ttl - 1
      }
    end

    def peer_host(peer_id)
      "http://localhost:#{peer_id}"
    end

    def message_to_s(m)
      msg = ""
      msg += "#{m[:uuid]} " if m[:uuid]
      msg += "id=#{m[:client_id]} " if m[:client_id]
      msg += "ttl=#{m[:ttl]} " if m[:ttl]
      msg += "payload=#{m[:payload].to_s}" if m[:payload]
      msg
    end
  end
end
