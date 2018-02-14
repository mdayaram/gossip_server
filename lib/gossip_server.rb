require "optparse"
require "gossip_server/version"
require "gossip_server/gossiper"
require "gossip_server/scheduler"
require "gossip_server/server"

module GossipServer
  def self.run!
    options = {
      seed: nil,
      port: 8000,
      infection_factor: 2,
      default_ttl: 3,
      gossip_interval: 10,
      fickle_interval: 15,
      payloads_file: File.join(__dir__, "assets", "books.txt"),
    }

    OptionParser.new do |opts|
      opts.on(
        "--port N", Integer,
        "The port to listen gossip on; " +
        "defaults to #{options[:port]}"
      ) { |v| options[:port] = v }

      opts.on(
        "--seed N", Integer,
        "The seed port to fetch initial peers from; " +
        "defaults to no seeds"
      ) { |v| options[:seed] = v }

      opts.on(
        "--infection-factor N", Integer,
        "The number of nodes to gossip to when gossiping; " +
        "defaults to #{options[:infection_factor]}"
      ) { |v| options[:infection_factor] = v }

      opts.on(
        "--default-ttl N", Integer,
        "How many nodes messages will travel before being dropped; " +
        "defaults to #{options[:default_ttl]}"
      ) { |v| options[:default_ttl] = v }

      opts.on(
        "--gossip-interval N", Integer,
        "How often should the server gossip in integer seconds; " +
        "defaults to #{options[:gossip_interval]}"
      ) { |v| options[:gossip_interval] = v }

      opts.on(
        "--fickle-interval N", Integer,
        "How often in seconds the server changes it's mind about it's own payload; " +
        "defaults to #{options[:fickle_interval]}"
      ) { |v| options[:fickle_interval] = v }

      opts.on(
        "--payloads-file PATH", String,
        "The filepath to the different payloads a server can hold, separated by new lines; " +
        "defaults to #{options[:payloads_file]}"
      ) { |v| options[:payloads_file] = v }
    end.parse!

    gossiper = Gossiper.new(
      id: options[:port].to_s,
      seed_id: options[:seed].to_s,
      infection_factor: options[:infection_factor].to_i,
      default_ttl: options[:default_ttl].to_i
    )
    gossiper.fetch_peers!

    scheduler = Scheduler.new(
      gossiper: gossiper,
      gossip_interval: options[:gossip_interval],
      fickle_interval: options[:fickle_interval],
      payloads_file: options[:payloads_file]
    )
    scheduler.start!

    Server.set :scheduler, scheduler
    Server.set :gossiper, gossiper
    Server.set :port, options[:port]
    Server.run!
  end
end
