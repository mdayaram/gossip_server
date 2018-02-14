require "optparse"
require "gossip_server/version"
require "gossip_server/gossiper"
require "gossip_server/server"

module GossipServer
  def self.run!
    options = {
      seed: nil,
      port: 8000,
      infection_factor: 2,
      default_ttl: 2,
    }

    OptionParser.new do |opts|
      opts.on("--port N", Integer, "The port to listen gossip on; defaults to #{options[:port]}") do |v|
        options[:port] = v
      end

      opts.on("--seed N", Integer, "The seed port to fetch initial peers from; defaults to no seeds") do |v|
        options[:seed] = v
      end

      opts.on("--infection-factor N", Integer, "The number of nodes to gossip to when gossiping; defaults to #{options[:infection_factor]}") do |v|
        options[:infection_factor] = v
      end

      opts.on("--default-ttl N", Integer, "Time To Live for a message, in this case, how many nodes the message will travel before being dropped; defaults to #{options[:default_ttl]}") do |v|
        options[:default_ttl] = v
      end
    end.parse!

    gossiper = Gossiper.new(
      id: options[:port].to_s,
      seed_id: options[:seed].to_s,
      infection_factor: options[:infection_factor].to_i,
      default_ttl: options[:default_ttl].to_i
    )

    gossiper.fetch_peers!

    Server.set :gossiper, gossiper
    Server.set :port, options[:port]
    Server.run!
  end
end
