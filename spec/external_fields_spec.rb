# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExternalFields do
  describe ".external_fields" do
    describe "the association" do
      Temping.create :test_class do
        with_columns do |t|
          t.string :name
        end

        include ExternalFields # rubocop:disable RSpec/DescribedClass

        has_one :assoc,
                class_name: "AssociationTestClass"

        has_one :no_empties_assoc,
                class_name: "NoEmptiesAssociationTestClass"

        external_field :ext_field,
                       :assoc,
                       class_name: "AssociationTestClass"

        external_field :ext_field_using_underscore,
                       :assoc,
                       class_name: "AssociationTestClass",
                       underscore: true

        external_field :ext_field_using_empties_not_saved,
                       :no_empties_assoc,
                       class_name: "NoEmptiesAssociationTestClass",
                       save_empty: false
      end

      Temping.create :association_test_class do
        with_columns do |t|
          t.integer :test_class_id
          t.string :ext_field
          t.string :ext_field_using_underscore
        end

        belongs_to :test_class
      end

      Temping.create :no_empties_association_test_class do
        with_columns do |t|
          t.integer :test_class_id
          t.string :ext_field_using_empties_not_saved
        end

        belongs_to :test_class
      end

      # Clean up after each test. This is a lot lighter for these few tests than
      # trying to wrangle with RSpec-Rails to get transactional tests to work.
      after :each do
        TestClass.delete_all
        AssociationTestClass.delete_all
        NoEmptiesAssociationTestClass.delete_all
      end

      it "is not created or saved if unused" do
        e = TestClass.create!
        e.name = "TEST"
        e.save!
        expect(AssociationTestClass.count).to eq(0)
      end

      it "provides an accessor that does not build a new object" do
        e = TestClass.new(name: "Hello")

        e.assoc(use_original: true) # Access without creating
        e.save!
        expect(AssociationTestClass.count).to eq 0
      end

      shared_examples_for "A model with setters" do |external_field|
        it "returns the new value on assignment" do
          new_value = rand.to_s
          expect(
            TestClass.create!.send("#{external_field}=", new_value)
          ).to be(new_value)
        end
      end

      shared_examples_for "A model with getters" do |external_field, klass|
        it "is created if used" do
          e = TestClass.new.tap do |x|
            x.name = "Hello"
            x.send("#{external_field}=", "Field1")
          end
          e.save!

          expect(klass.count).to eq(1)
          expect(e.send(external_field)).to eq "Field1"
        end
      end

      context "when empty saves are enabled" do
        it_behaves_like "A model with getters", :ext_field, AssociationTestClass
        it_behaves_like "A model with setters", :ext_field

        it "is saved when the default associated model is read" do
          e = TestClass.create!(name: "Hello")
          expect(AssociationTestClass.count).to eq(0)
          expect(e.assoc.class).to eq(AssociationTestClass)
          e.save!
          expect(AssociationTestClass.count).to eq(1)
        end

        it "saves explicitly specified empty values" do
          e = TestClass.create!
          e.name = "TEST"
          e.ext_field = nil
          e.save!
          expect(AssociationTestClass.count).to eq(1)
        end

        it "returns association value with id" do
          e = TestClass.create!
          e.name = "TEST"
          expect(e.assoc).to_not be_nil
          expect(e.assoc.id).to_not be_nil
        end
      end

      context "when empty saves are disabled" do
        it_behaves_like "A model with getters",
                        :ext_field_using_empties_not_saved,
                        NoEmptiesAssociationTestClass
        it_behaves_like "A model with setters",
                        :ext_field_using_empties_not_saved

        it "is not saved when the default associated model is read" do
          e = TestClass.create!(name: "Hello")
          expect(e.assoc.class).to eq(AssociationTestClass)
          e.save!
          expect(NoEmptiesAssociationTestClass.count).to eq(0)
        end

        it "does not save empty values" do
          e = TestClass.create!
          e.name = "TEST"
          e.ext_field_using_empties_not_saved = nil
          e.save!
          expect(NoEmptiesAssociationTestClass.count).to eq(0)
        end

        it "does save non-empty values" do
          e = TestClass.create!
          e.name = "TEST"
          e.ext_field_using_empties_not_saved = "Another test"
          e.save!
          expect(NoEmptiesAssociationTestClass.count).to eq(1)
        end

        it "returns association value without id" do
          e = TestClass.create!
          e.name = "TEST"
          expect(e.no_empties_assoc).to_not be_nil
          expect(e.no_empties_assoc.id).to be_nil
        end
      end
    end
  end
end
