require "./spec_helper"
require "./couchdb-orm/**"

describe CouchDB::ORM do

  describe "#get_client" do
    it "should get client" do
      client = CouchDB::ORM::Client.get("http://127.0.0.1:5984")
      client.class.should eq CouchDB::Client
    end
  end
end
