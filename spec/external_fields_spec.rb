require "spec_helper"

RSpec.describe ExternalFields, :temporal do
  describe ".external_fields" do
    describe "the association" do
      Temping.create :test_class do
        with_columns do |t|
          t.string :name
        end

        include ExternalFields

        has_one :assoc,
                class_name: "AssociationTestClass"

        external_field :ext_field_1,
                       :assoc,
                       class_name: "AssociationTestClass"

        external_field :ext_field_2,
                       :assoc,
                       class_name: "AssociationTestClass",
                       underscore: true
      end

      Temping.create :association_test_class do
        with_columns do |t|
          t.integer :test_class_id
          t.string :ext_field_1
          t.string :ext_field_2
        end

        belongs_to :test_class
      end

      # Clean up after each test. This is a lot lighter for these few tests than
      # trying to wrangle with RSpec-Rails to get transactional tests to work.
      after :each do
        TestClass.delete_all
        AssociationTestClass.delete_all
      end

      it "should be built on first access" do
        e = TestClass.create!(name: "Hello")

        expect(AssociationTestClass.count).to eq(0)
        expect(e.assoc.class).to eq(AssociationTestClass)
      end

      it "should be saved when the model is saved" do
        e = TestClass.create!(name: "Hello")
        expect(AssociationTestClass.count).to eq(0)
        expect(e.assoc.class).to eq(AssociationTestClass)
        e.save!
        expect(AssociationTestClass.count).to eq(1)
      end

      it "should not be created or saved if unused" do
        e = TestClass.create!
        e.name = "TEST"
        e.save!
        expect(AssociationTestClass.count).to eq(0)
      end

      it "should be created if used" do
        e = TestClass.create!(name: "Hello", ext_field_1: "Field1")

        expect(AssociationTestClass.count).to eq(1)
        expect(e.ext_field_1).to eq "Field1"
      end

      context "when underscore flag is true" do
        it "should provide underscored methods" do
          e = TestClass.create!(_ext_field_2: "_Field2")

          expect(AssociationTestClass.count).to eq(1)
          expect(e._ext_field_2).to eq "_Field2"
        end
      end

      it "should provide an accessor that does not build a new object" do
        e = TestClass.new(name: "Hello")

        e.assoc(use_original: true) # Access without creating
        e.save!
        expect(AssociationTestClass.count).to eq 0
      end
    end
  end
end
