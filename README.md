[![Codacy Badge](https://app.codacy.com/project/badge/Grade/e42289cb87e44d8eb25d4255e395d9e1)](https://www.codacy.com/gh/AnthonyTestOrg/rails_external_fields/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=AnthonyTestOrg/rails_external_fields&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/e42289cb87e44d8eb25d4255e395d9e1)](https://www.codacy.com/gh/AnthonyTestOrg/rails_external_fields/dashboard?utm_source=github.com&utm_medium=referral&utm_content=AnthonyTestOrg/rails_external_fields&utm_campaign=Badge_Coverage)

# NOTE: This is a test repo

# ExternalFields
Create the illusion that an object has specific attributes when those attributes
actually belong to an associated object.

This is particularly useful for different classes within a single-
table inheritance table to have access to separate fields in class-specific
associations.

## Installation
Add this line to your application's Gemfile:

```
gem "external_fields"
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install external_fields
```

## Usage
Include `ExternalFields` and define the external fields using the `external_field` method. For example, if `grade_level`, `age` and `credits` are defined in another class `StudentData` and you want to access them in `Student` you could do:

```ruby
require "active_record"
require "active_support"

require "external_fields"

class Student < ActiveRecord::Base
  include ExternalFields

  has_one :data,
          class_name: StudentData

  external_field :grade_level,              # External attribute 1
                 :age,                      # External attribute 2
                 :credits,                  # External attribute 3
                 :data,                     # Name of the association
                 class_name: "StudentData", # Class name of association
                 save_empty: false          # Don't save empty associations
end
```

where the external fields are defined in another associated class:

```ruby
class StudentData < ActiveRecord::Base
  attr_accessor :grade_level, :age, :credits
end
```

Now you can directly call the accessors on the `Student` objects:

```ruby
 > s = Student.create!
 > s.age
=> nil

 > s.age = 10
 > s.age
=> 10

 > s.grade_level = 4
 > s.grade_level
=> 4
```

### Overriding default behavior using `underscored` accessors
You can also add underscored accessors using the `underscore` flag

```ruby
...
  external_field :grade_level,             # External attribute 1
                 :age,                     # External attribute 2
                 :credits,                 # External attribute 3
                 :data,                    # Name of the association
                 class_name: "StudentData" # Class name of association
                 underscore: true          # Flag for underscored accessors
...
```

This will allow you to use the external fields using underscored methods:
```ruby
s = Student.create!
s._age
s._grade_level
```

This approach lets you override the default behavior cleanly. For example,
you could override the grade level using this method:

```ruby
def grade_level
  if _grade_level == 0
    "Kindergarten"
  else
    _grade_level
  end
end
```

### Overriding default behavior using `save_empty: false`
**This is the recommended configuration to use for all new code.**

To avoid unnecessary writes, you can rely on empty-valued class instances so
that external associations are only saved when they have one or more attributes
with non-default values.

For any given association class, its constructor defines the attribute values
for an "empty" instance. This means that, in the below example, retreival of
`data` will return `StudentData.new` if there's no `StudentData` record saved.
If `set_empty: true` were configured instead, calling `data` would still return
`StudentData.new`, but it would also write the empty record to the database.

```ruby
  external_field :grade_level,              # External attribute 1
                 :age,                      # External attribute 2
                 :credits,                  # External attribute 3
                 :data,                     # Name of the association
                 class_name: "StudentData", # Class name of association
                 save_empty: false          # Don't save empty associations
```

The default value for `save_empty` is `true` only for backward compatability, 
as existing code using this gem may rely on empty rows existing in a database.

### Accessing the original association

In some instances it's helpful to be able to use the original association
without building an object on access. For instance, you might want to have a
validation inspect a value without creating a new object on each save. In that
case, you can use the `use_original` flag on the association like so:

```ruby
validate :kindergarten_students_have_names

def kindergarten_students_have_names
  data_obj = data(use_original: true)

  if data_obj && grade_level == "Kindergarten" && name.blank?
    # Note that `name` is an attribute on `Student` but `grade_level`
    # is accessed through the `data` association as defined earlier
    # in the README.
    errors.add(:name, "must be present for kindergarten students")
  end
end
```

## Documentation

We have documentation on [RubyDoc](http://www.rubydoc.info/github/panorama-ed/rails_external_fields/main).

## Contributing

1. Fork it (https://github.com/panorama-ed/rails_external_fields/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

**Make sure your changes have appropriate tests (`bundle exec rspec`)
and conform to the Rubocop style specified.** We use
[overcommit](https://github.com/causes/overcommit) to enforce good code.

## License

`ExternalFields` is released under the
[MIT License](https://github.com/panorama-ed/rails_external_fields/blob/main/LICENSE).
