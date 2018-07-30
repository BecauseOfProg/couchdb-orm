require "../spec_helper"

class Animal < CouchDB::ORM::Model

  fields(
    race: String,
    age: Int32
  )

end

describe CouchDB::ORM do

  describe "Animal" do
    animal = Animal.new race: "Dog", age: 5
    initialize_client

    describe "#race" do
      it "should get race" do
        animal.race.should eq "Dog"
      end
    end

    describe "#race=" do
      it "should change race" do
        animal.race = "Cat"
        animal.race.should_not eq "Dog"
        animal.race.should eq "Cat"
      end
    end

    describe "#new" do
      it "should be an Animal" do
        animal.class.should eq Animal
      end
      it "should complete nil" do
        animal2 = Animal.new
        animal2.class.should eq Animal
        animal2.race.should eq nil
        animal2.age.should eq nil
      end
    end

    describe "#create_database" do

      it "should create database" do
        Animal.create_database.should be_true
      end

    end

    describe "#save" do

      it "should save" do
        animal.save.should be_true
      end

      it "should update" do
        animal.race = "Dog"
        animal.save.should be_true
      end

    end

    describe "#get" do

      it "should get" do
        id = animal.id.as(String)
        if id
          animal2 = Animal.get(id)
          animal2.class.should eq Animal
          animal2.as(Animal).race.should eq animal.race
          animal2.as(Animal).age.should eq animal.age
        end
      end
    end

    describe "#get_by" do

      it "should get by race" do
        id = animal.id.as(String)
        if id
          animals = Animal.get_by(:race, "Dog")
          animals.class.should eq Array(Animal)
          animals.size.should eq 1
          animals.first.race.should eq animal.race
          animals.first.age.should eq animal.age
        end
      end
    end

    describe "#destroy" do

      it "should destroy" do
        animal.destroy.should be_true
      end

    end

    describe "#destroy_database" do

      it "should destroy database" do
        Animal.destroy_database.should be_true
      end

    end

    it "should work" do
      Animal.create_database.should be_true

      animal = Animal.new race: "Dog", age: 5
      animal.save.should be_true

      animal.race = "Cat"
      animal.save.should be_true

      animal2 = Animal.get(animal.id.as(String)).as(Animal)
      animal2.race.should eq animal.race
      animal3 = Animal.get_by(:race, "Cat").first.as(Animal)
      animal3.age.should eq animal.age
      animal2.race = "Horse"
      animal2.save
      animal.get
      animal.race.should eq "Horse"

      animal.destroy.should be_true # Bool

      Animal.destroy_database.should be_true
    end

  end
end
