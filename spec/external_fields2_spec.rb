# frozen_string_literal: true

require "spec_helper"
require 'external_fields2'

RSpec.describe ExternalFields2 do
  describe ".external_fields2" do
    describe "the association" do
      Temping.create :test_class2 do
        with_columns do |t|
          t.string :name
        end

        include ExternalFields2 # rubocop:disable RSpec/DescribedClass

        has_one :assoc,
                class_name: "AssociationTestClass2"

        has_one :no_empties_assoc,
                class_name: "NoEmptiesAssociationTestClass2"

        external_field :ext_field,
                       :assoc,
                       class_name: "AssociationTestClass2"

        external_field :ext_field_using_underscore,
                       :assoc,
                       class_name: "AssociationTestClass2",
                       underscore: true

        external_field :ext_field_using_empties_not_saved,
                       :no_empties_assoc,
                       class_name: "NoEmptiesAssociationTestClass2",
                       save_empty: false
      end

      Temping.create :association_test_class2 do
        with_columns do |t|
          t.integer :test_class2_id
          t.string :ext_field
          t.string :ext_field_using_underscore
        end

        belongs_to :test_class2
      end

      Temping.create :no_empties_association_test_class2 do
        with_columns do |t|
          t.integer :test_class2_id
          t.string :ext_field_using_empties_not_saved
        end

        belongs_to :test_class2
      end

      # Clean up after each test. This is a lot lighter for these few tests than
      # trying to wrangle with RSpec-Rails to get transactional tests to work.
      after :each do
        TestClass2.delete_all
        AssociationTestClass2.delete_all
        NoEmptiesAssociationTestClass2.delete_all
      end

      it "is not created or saved if unused" do
        e = TestClass2.create!
        e.name = "TEST"
        e.save!
        expect(AssociationTestClass2.count).to eq(0)
      end

      it "provides an accessor that does not build a new object" do
        e = TestClass2.new(name: "Hello")

        e.assoc(use_original: true) # Access without creating
        e.save!
        expect(AssociationTestClass2.count).to eq 0
      end

      shared_examples_for "A model with setters" do |external_field|
        it "returns the new value on assignment" do
          new_value = rand.to_s
          expect(
            TestClass2.create!.send("#{external_field}=", new_value)
          ).to be(new_value)
        end
      end

      shared_examples_for "A model with getters" do |external_field, klass|
        it "is created if used" do
          e = TestClass2.new.tap do |x|
            x.name = "Hello"
            x.send("#{external_field}=", "Field1")
          end
          e.save!

          expect(klass.count).to eq(1)
          expect(e.send(external_field)).to eq "Field1"
        end
      end

      context "when empty saves are enabled" do
        it_behaves_like "A model with getters", :ext_field, AssociationTestClass2
        it_behaves_like "A model with setters", :ext_field

        it "is saved when the default associated model is read" do
          e = TestClass2.create!(name: "Hello")
          expect(AssociationTestClass2.count).to eq(0)
          expect(e.assoc.class).to eq(AssociationTestClass2)
          e.save!
          expect(AssociationTestClass2.count).to eq(1)
        end

        it "saves explicitly specified empty values" do
          e = TestClass2.create!
          e.name = "TEST"
          e.ext_field = nil
          e.save!
          expect(AssociationTestClass2.count).to eq(1)
        end

        it "returns association value with id" do
          e = TestClass2.create!
          e.name = "TEST"
          expect(e.assoc).to_not be(nil)
          expect(e.assoc.id).to_not be(nil)
        end
      end

      context "when empty saves are disabled" do
        it_behaves_like "A model with getters",
                        :ext_field_using_empties_not_saved,
                        NoEmptiesAssociationTestClass2
        it_behaves_like "A model with setters",
                        :ext_field_using_empties_not_saved

        it "is not saved when the default associated model is read" do
          e = TestClass2.create!(name: "Hello")
          expect(e.assoc.class).to eq(AssociationTestClass2)
          e.save!
          expect(NoEmptiesAssociationTestClass2.count).to eq(0)
        end

        it "does not save empty values" do
          e = TestClass2.create!
          e.name = "TEST"
          e.ext_field_using_empties_not_saved = nil
          e.save!
          expect(NoEmptiesAssociationTestClass2.count).to eq(0)
        end

        it "does save non-empty values" do
          e = TestClass2.create!
          e.name = "TEST"
          e.ext_field_using_empties_not_saved = "Another test"
          e.save!
          expect(NoEmptiesAssociationTestClass2.count).to eq(1)
        end

        it "returns association value without id" do
          e = TestClass2.create!
          e.name = "TEST"
          expect(e.no_empties_assoc).to_not be(nil)
          expect(e.no_empties_assoc.id).to be(nil)
        end
      end
    end
  end
end
