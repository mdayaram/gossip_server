require 'rufus-scheduler'

module GossipServer
  class Scheduler
    include Logging

    attr_reader :gossiper
    attr_reader :gossip_interval
    attr_reader :fickle_interval

    attr_reader :scheduler

    def initialize(gossiper:, gossip_interval:, fickle_interval: nil)
      @gossiper = gossiper
      @gossip_interval = gossip_interval
      @fickle_interval = fickle_interval

      @scheduler = Rufus::Scheduler.new
      fickle_run if fickle_interval.to_i > 0 # pick something right away.
    end

    def start!
      debug "starting schedules"

      scheduler.every "#{gossip_interval}s" do
        gossip_run
      end

      if fickle_interval.to_i > 0
        scheduler.every "#{fickle_interval}s" do
          fickle_run
        end
      end
    end

    def stop!
      debug "stopping schedule"
      scheduler.shutdown
    end

    def stopped?
      scheduler.down?
    end

    private

    def fickle_run
      new_payload = gossiper.world_state.next_state
      debug "picking a new payload: #{new_payload.to_s}"
      gossiper.add_payload(new_payload)
    end

    def gossip_run
      debug "gossiping to my peers"
      gossiper.gossip_peers!
    end
  end
end
