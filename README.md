# GossipServer

# Building a gossip protocol

## Goal
We're going to build a gossip protocol that gossips with a network of peers about their current favorite books. Each node will connect to only one other node, and all nodes should know the favorite books of all other nodes in the system. We'll have nodes run as separate processes on different ports on your local machine, and they'll pass JSON-encoded messages via HTTP (to make our lives easier).

## State
We'll use a gossip protocol to keep track of each node's current favorite book. You can find a list of books in `books.txt`.

Each node's book should be randomly re-sampled from the pool of all books once every ~10 seconds. Once it chooses a new favorite book, it should flood its peers with this message.

You need to have each node keep track of their own incrementing version number, so we can keep track of their state and order messages. In a gossip protocol we will often receive messages out of order, so we need to know which one is most recent.

The node should also keep a cache of the recent messages it's received. Normally we'd want to cull this, but for now we can just let it grow in memory.

## Endpoints
For simplicity, we'll bootstrap the network with one other node. That argument will be passed via the command line.

Each node needs the endpoints:

* GET /peers/ (for bootstrapping into the network)
* POST /gossip/ (for sending gossip between nodes)

## Message format
Your messages will need the following:

* UUID (for deduplication)
* Originating port (your identity)
* Version number
* TTL
* Payload

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gossip_server'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gossip_server

## Usage

Simply start the server by running `bin/gossip_server` optionally passing an
argument for the seed peer like so:

```bash
$> bin/gossip_server --seed 5000
```

You can also specify the port for this gossip server to listen on.

```bash
$> bin/gossip_server --port 12345 --seed 5000
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mdayaram/gossip_server.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
