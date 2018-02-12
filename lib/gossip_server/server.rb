require "sinatra/base"
require "json"

module GossipServer
  class Server < Sinatra::Base
    get "/peers" do
      client = get_client_port
      result = settings.gossiper.peers_handler(client: client)
      JSON.generate(result)
    end

    post "/gossip" do
      client = get_client_port
      body = JSON.parse(request.body.read)
      result = settings.gossiper.gossip_handler(client: client, body: body)
      JSON.generate(result)
    end

    private

    def get_client_port
      raise "Need hijacking API to get client port!" if !request.env['rack.hijack?']
      request.env['rack.hijack'].call
      io = request.env['rack.hijack_io']
      io.peeraddr[1]
    end
  end
end
