module CouchDB::ORM
  # Model class, base of whole this shit
  # To create a model class
  # ```require "couchdb-orm"
  #
  #CouchDB::ORM::Client.get("http://127.0.0.1:5984") # Mandatory, used everywhere to save, update, destroy
  #
  #class Animal < CouchDB::ORM::Model
  #
  #  fields(
  #    race: String, # name: type
  #    age: Int32
  #  )
  #
  #end```
  class Model
    @id : String?
    @rev : String?
    getter id, rev

    macro fields(**fields)
      {% fields_names = [] of String %}
      {% for k, v in fields %}
        property {{k}} : {{v}}? # Set property to have getter and setter
        {% fields_names << k.symbolize %}
      {% end %}

      # Get fields names
      private def get_fields() : Array(Symbol)
        {{fields_names}}
      end
      # Get fields names
      private def self.get_fields() : Array(Symbol)
        {{fields_names}}
      end

      # Get database name
      private def self.database() : String
        {{@type.name}}.to_s.downcase
      end
      # Get database name
      private def database() : String
        {{@type.name}}.to_s.downcase
      end

      private def set_fields(
        {% for k, v in fields %}
          {{k}} : {{v}}? = nil,
          {% end %}
          id = nil, rev = nil
        )
        {% for k, v in fields %}
          @{{k}} = {{k}}
        {% end %}
        @id = id
      end
      private def fields_values() : Hash(Symbol, {% for k, v in fields %}{{v}}|{% end %}String|Nil)
        values = {} of Symbol => ({% for k, v in fields %}{{v}}|{% end %}Nil)
        {% for k, v in fields %}
          values[:{{k}}] = @{{k}}
        {% end %}
        if @rev
          values[:_rev] = @rev
        end
        values
      end
      def from_json(json : Hash(String, JSON::Any))
        json.each do |k,v|
          {% for k, v in fields %}
            if k == "{{k}}"
              {% if v.symbolize == :String %}
                @{{k}} = v.as_s?
              {% elsif v.symbolize == :Int32 %}
                @{{k}} = v.as_i?
              {% elsif v.symbolize == :Int64 %}
                @{{k}} = v.as_i?
              {% elsif v.symbolize == :Float %}
                @{{k}} = v.as_f?
              {% elsif v.symbolize == :Bool %}
                @{{k}} = v.as_bool?
              {% end %}
            end
          {% end %}
          if k == "_id"
            @id = v.as_s?
          end
          if k == "_rev"
            @rev = v.as_s?
          end
        end
      end
      def get() : self
        updated = self.class.get(id.as(String)).as(Animal)
        {% for k, v in fields %}
          @{{k}} = updated.{{k}}
        {% end %}
        @rev = updated.rev
        return self
      end
    end

    # Create new model from an named tuple
    def initialize(**opt)
      set_fields(**opt)
    end

    # Save in database
    # Should return true
    def save : Bool
      client = Client.get.as(CouchDB::Client)
      if client
        if id
          resp = client.update_document(database, id, fields_values)
          @rev = resp.rev
        else
          resp = client.create_document(database, fields_values)
          @id = resp.id
          @rev = resp.rev
        end
        return resp.ok?
      end
      false
    end

    # Destroy from database
    # Var not destroyed
    # Should return true
    def destroy : Bool
      client = Client.get.as(CouchDB::Client)
      if client
        resp = client.delete_document(database, id, rev)
        if resp.ok?
          @id = nil
          @rev = nil
          return true
        end
      end
      false
    end

    # Get model from id
    # Should return model or nil if doesn't exists
    def self.get(id : String) : self?
      client = Client.get.as(CouchDB::Client)
      if client
        query = CouchDB::FindQuery.from_json "{\"selector\": { \"_id\": {\"$eq\": \"" + id + "\"} } }"
        resp = client.find_document(database, query)
        if resp.docs
          resp = resp.docs.as(Array(JSON::Any))
          if resp && resp.size > 0
            model = self.new
            model.from_json(resp.first.as_h)
          end
          return model
        end
      end
    end

    # Get model from one field
    # Should return array of model
    def self.get_by(name, value) : Array(self)
      client = Client.get.as(CouchDB::Client)
      models = Array(self).new
      if client
        if get_fields.includes?(name)
          query = CouchDB::FindQuery.from_json "{\"selector\": { \"" + name.to_s + "\": {\"$eq\": \"" + value + "\"} } }"
          resp = client.find_document(database, query)
          if resp.docs
            resp.docs.as(Array(JSON::Any)).each do |v|
              model = self.new
              model.from_json(v.as_h)
              models << model
            end
          end
        end
      end
      return models
    end

    # Create database
    # Only first time
    # Should return true
    def self.create_database : Bool
      client = Client.get.as(CouchDB::Client)
      if client
        resp = client.create_database(self.database)
        return resp.ok?
      end
      false
    end

    # Destroy database
    # Caution data destroyed
    # Should return true
    def self.destroy_database : Bool
      client = Client.get.as(CouchDB::Client)
      if client
        resp = client.delete_database(self.database)
        return resp.ok?
      end
      false
    end
  end
end
