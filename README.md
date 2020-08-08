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
