module GossipServer
  class WorldState
    def update_world_state(client_id:, payload:)
      raise NotImplementedError
    end

    def my_s
      raise NotImplementedError
    end

    def to_s
      raise NotImplementedError
    end
  end
end
