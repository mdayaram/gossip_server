require "sinatra/base"
require "json"

module GossipServer
  class Server < Sinatra::Base
    get "/peers" do
      client = request.port.to_i
      result = settings.gossiper.peers(client: client)
      JSON.generate(result)
    end

    post "/gossip" do
      client = request.port.to_i
      body = JSON.parse(request.body.read)
      result = settings.gossiper.gossip(client: client, body: body)
      JSON.generate(result)
    end
  end
end
