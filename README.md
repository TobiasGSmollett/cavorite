# Cavorite

Cavorite is an actor model library for Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cavorite:
       github: tobiasgsmollett/cavorite
   ```

2. Run `shards install`

## Usage

```crystal
require "cavorite"

include Cavorite::Core

class HelloActor < Actor(String)
  @count : Int32

  def initialize(name : String)
    super(name)
    @count = 0
  end

  def handler(msg : ActorMessage): String
    @count += 1
    if msg.is_a?(HelloMessage)
      "hello #{msg.text} #{@count.to_s}"
    else
      "error"
    end
  end
end

class HelloMessage < UserMessage
  property text : String
  def initialize(@text : String)
  end
end

actor_system = Cavorite::Core::System.new("hello_actor_system")
actor_system.create("/", "hello_supervisor", Supervisor)
actor_ref = actor_system.create("/hello_supervisor", "hello_actor", HelloActor)

msg = HelloMessage.new("world")

channel = Cavorite::Core::System.send(actor_ref.as(ActorRef), msg)
puts channel.as(Channel(String)).receive
```

TODO: Write usage instructions here

## Development

Required `-Dpreview_mt` option when you run codes of this repository.

```sh
$ crystal spec -Dpreview_mt 
$ crystal spec -Dpreview_mt spec/<filename>.cr

# You can see benchmarks.
$ crystal run --release -Dpreview_mt bench/<filename>.cr
```

## Contributing

1. Fork it (<https://github.com/tobiasgsmollett/cavorite/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [tobya](https://github.com/TobiasGSmollett) - creator and maintainer
