require "sinatra/base"
require "json"

module GossipServer
  class Server < Sinatra::Base
    get "/peers/:client_id" do
      result = settings.gossiper.peers_handler(client_id: params[:client_id])
      JSON.generate(result)
    end

    post "/gossip" do
      msg = JSON.parse(request.body.read)
      result = settings.gossiper.gossip_handler(msg)
      JSON.generate(result)
    end
  end
end
