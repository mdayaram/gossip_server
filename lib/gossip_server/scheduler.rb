require 'rufus-scheduler'

module GossipServer
  class Scheduler
    attr_reader :gossiper
    attr_reader :gossip_interval
    attr_reader :fickle_interval
    attr_reader :possible_payloads

    attr_reader :scheduler

    def initialize(gossiper:, gossip_interval:, fickle_interval:, payloads_file:)
      @gossiper = gossiper
      @gossip_interval = gossip_interval
      @fickle_interval = fickle_interval

      @scheduler = Rufus::Scheduler.new
      @possible_payloads = File.read(payloads_file).split("\n")
      fickle_run # pick something right away.
    end

    def start!
      scheduler.every "#{gossip_interval}s" do
        gossip_run
      end

      scheduler.every "#{fickle_interval}s" do
        fickle_run
      end
    end

    def stop!
      scheduler.shutdown
    end

    def stopped?
      scheduler.down?
    end

    private

    def fickle_run
      new_payload = possible_payloads.sample
      gossiper.change_my_mind(new_payload)
    end

    def gossip_run
      gossiper.gossip_peers!
    end
  end
end
