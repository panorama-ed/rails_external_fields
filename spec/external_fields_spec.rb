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

      it "should be saved when employee is saved" do
        e = Fabricate(:employee)
        expect(SIS::EmployeeData.count).to eq(0)
        expect(e.extra_data.class).to eq(SIS::EmployeeData)
        e.save!
        expect(SIS::EmployeeData.count).to eq(1)
      end

      it "should not be created or saved if unused" do
        e = Fabricate(:employee)
        e.first_name = "TEST"
        e.save!
        expect(SIS::EmployeeData.count).to eq(0)
      end

      # This test is checking that student_friendly_name goes through
      # extra_data.
      it "should be created if used" do
        e = Fabricate(:employee, student_friendly_name: "TEST")
        expect(SIS::EmployeeData.count).to eq(1)
        expect(e.student_friendly_name).to eq "TEST"
      end

      # This test also checks that student_friendly_name goes through
      # extra_data.
      it "should provide underscored methods" do
        e = Fabricate(:employee, _student_friendly_name: "TEST")
        expect(SIS::EmployeeData.count).to eq(1)
        expect(e._student_friendly_name).to eq "TEST"
      end

      it "should provide an accessor that does not build a new object" do
        e = Fabricate.build(:employee)
        e.extra_data(use_original: true) # Access without building.
        e.save!
        expect(SIS::EmployeeData.count).to eq 0
      end
    end
  end
end
