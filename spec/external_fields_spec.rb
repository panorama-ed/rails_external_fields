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

        external_field :ext_field1,
                       :assoc,
                       class_name: "AssociationTestClass"

        external_field :ext_field2,
                       :assoc,
                       class_name: "AssociationTestClass",
                       underscore: true
      end

      Temping.create :association_test_class do
        with_columns do |t|
          t.integer :test_class_id
          t.string :ext_field1
          t.string :ext_field2
        end

        belongs_to :test_class
      end

      # Clean up after each test. This is a lot lighter for these few tests than
      # trying to wrangle with RSpec-Rails to get transactional tests to work.
      after :each do
        TestClass.delete_all
        AssociationTestClass.delete_all
      end

      it "is built on first access" do
        e = TestClass.create!(name: "Hello")

        expect(AssociationTestClass.count).to eq(0)
        expect(e.assoc.class).to eq(AssociationTestClass)
      end

      it "is saved when the model is saved" do
        e = TestClass.create!(name: "Hello")
        expect(AssociationTestClass.count).to eq(0)
        expect(e.assoc.class).to eq(AssociationTestClass)
        e.save!
        expect(AssociationTestClass.count).to eq(1)
      end

      it "is not created or saved if unused" do
        e = TestClass.create!
        e.name = "TEST"
        e.save!
        expect(AssociationTestClass.count).to eq(0)
      end

      it "is created if used" do
        e = TestClass.create!(name: "Hello", ext_field1: "Field1")

        expect(AssociationTestClass.count).to eq(1)
        expect(e.ext_field1).to eq "Field1"
      end

      context "when underscore flag is true" do
        it "provides underscored methods" do
          e = TestClass.create!(_ext_field2: "_Field2")

          expect(AssociationTestClass.count).to eq(1)
          expect(e._ext_field2).to eq "_Field2"
        end
      end

      it "provides an accessor that does not build a new object" do
        e = TestClass.new(name: "Hello")

        e.assoc(use_original: true) # Access without creating
        e.save!
        expect(AssociationTestClass.count).to eq 0
      end
    end
  end
end
