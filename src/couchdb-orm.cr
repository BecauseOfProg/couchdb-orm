require "couchdb"
require "./couchdb-orm/*"

# An simple CouchDB ORM
module CouchDB::ORM

  class Client
    @@client : CouchDB::Client? = nil

    def self.get(uri : String? = nil) : CouchDB::Client?
      if uri
        client = CouchDB::Client.new(uri)
        if client.server_info.is_a?(CouchDB::Response::ServerInfo)
          @@client = client
        end
      end
      @@client
    end

  end
end
