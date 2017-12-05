# Shipgate-Soap Wrapper for ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'postat'
```

And then execute:
```shell
$ bundle
```
Or install it yourself as:
```shell
$ gem install postat
```

##### After bundle
```shell
$ rails g postat
```
This adds the following:
* `config/initializers/postat.rb`

* `config/postat.yml`
  `config/postat-example.yml`
```yml
development:
  guid:       'guid'
  username:   'username'
  password:   'password'
  namespace:  'http://example.com/'
  wsdl:       'http://example.com/soap?WSDL'
```

* `.gitignore`
```
config/postat.yml
```

## Usage
This Gem provides you with a Wrapper for the Shipgate-Soap-Api


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/datyv/postat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
