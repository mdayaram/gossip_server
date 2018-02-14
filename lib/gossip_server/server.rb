require "sinatra/base"
require "json"

module GossipServer
  class Server < Sinatra::Base
    get "/peers/:client_id" do
      result = settings.gossiper.peers_handler(client_id: params[:client_id])
      JSON.generate(result)
    end

    post "/gossip" do
      msg = JSON.parse(request.body.read, symbolize_names: true)
      result = settings.gossiper.gossip_handler(msg)
      JSON.generate(result)
    end

    get "/" do
      content_type "text/plain"
      settings.gossiper.to_s
    end
  end
end
