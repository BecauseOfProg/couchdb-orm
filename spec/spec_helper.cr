require "spec"
require "../src/couchdb-orm"

def initialize_client()
  CouchDB::ORM::Client.get("http://127.0.0.1:5984")
end
