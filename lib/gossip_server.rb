require "optparse"
require "gossip_server/version"
require "gossip_server/gossiper"
require "gossip_server/server"

module GossipServer
  def self.run!
    options = {
      seed: 0,
      port: 8000
    }

    OptionParser.new do |opts|
      opts.on("--port N", Integer, "The port to listen gossip on; defaults to #{options[:port]}") do |v|
        options[:port] = v
      end

      opts.on("--seed N", Integer, "The seed port to fetch initial peers from; defaults to no seeds") do |v|
        options[:seed] = v
      end
    end

    Server.set :gossiper, Gossiper.new(port: options[:port], seed: options[:seed])
    Server.set :port, options[:port]
    Server.run!
  end
end
