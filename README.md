# couchdb-orm
[![Build Status](https://api.travis-ci.org/Whaxion/couchdb-orm.svg?branch=master)](https://travis-ci.org/Whaxion/couchdb-orm)

A simple CouchDB ORM based on [TechMagister CouchDB Client](https://github.com/TechMagister/couchdb.cr)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  couchdb-orm:
    github: Whaxion/couchdb-orm
```

## Usage
An example explain better than a long text, so

```crystal
require "couchdb-orm"

CouchDB::ORM::Client.get("http://127.0.0.1:5984") # Mandatory, used everywhere to save, update, destroy

class Animal < CouchDB::ORM::Model

  fields(
    race: String, # name: type
    age: Int32
  )

end

Animal.create_database # Create database, only first time, must be removed once created

animal = Animal.new race: "Dog", age: 5
animal.save # Bool

animal.race = "Cat"
animal.save # Bool

animal2 = Animal.get(animal.id) # Get model from id
animal3 = Animal.get_by(:race, "Cat").first # Get models from field

animal.destroy # Bool

Animal.destroy_database # Destroy database, caution all data is deleted
```

## Contributing

1. Fork it (<https://github.com/Whaxion/couchdb-orm/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Whaxion](https://github.com/Whaxion) Whaxion - creator, maintainer
