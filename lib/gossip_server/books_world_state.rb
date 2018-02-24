module GossipServer
  class BooksWorldState < WorldState
    attr_reader :world_state
    attr_reader :my_id
    attr_reader :possible_books

    def initialize(id: , books_file:)
      @my_id = id
      @world_state = { my_id => { version: 0, book: "" } }
      @possible_books = File.read(books_file).split("\n")
    end

    def update_world_state(client_id:, payload:)
      version = payload[:version]
      book = payload[:book]

      if world_state[client_id].nil?
        world_state[client_id] = {version: version, book: book}
      elsif world_state[client_id][:version] < version
        world_state[client_id] = {version: version, book: book}
      else
        world_state[client_id] # Keep current state, version was older.
      end
    end

    def my_s
      state_of_id_s(my_id)
    end

    def to_s
      world_state.keys.sort.map do |id|
        state_of_id_s(id)
      end.join("\n")
    end

    def next_state
      {
        version: world_state[my_id][:version] + 1,
        book: possible_books.sample
      }
    end

    private

    def state_of_id_s(mid)
      "id=#{mid} v=#{world_state[mid][:version]} book=#{world_state[mid][:book].to_s}"
    end
  end
end
