[![Code Climate](https://codeclimate.com/github/panorama-ed/rails_external_fields/badges/gpa.svg)](https://codeclimate.com/github/panorama-ed/rails_external_fields) [![Test Coverage](https://codeclimate.com/github/panorama-ed/rails_external_fields/badges/coverage.svg)](https://codeclimate.com/github/panorama-ed/rails_external_fields) [![Build Status](https://travis-ci.org/panorama-ed/rails_external_fields.svg)](https://travis-ci.org/panorama-ed/rails_external_fields) [![Inline docs](http://inch-ci.org/github/panorama-ed/rails_external_fields.png)](http://inch-ci.org/github/panorama-ed/rails_external_fields) [![Gem Version](https://badge.fury.io/rb/rails_external_fields.svg)](http://badge.fury.io/rb/rails_external_fields)

# ExternalFields
Create the illusion that an object has specific attributes when those attributes
actually belong to an associated object.

This is particularly useful for different classes within a single-
table inheritance table to have access to separate fields in class-specific
associations.

## Installation
Add this line to your application's Gemfile:

````
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
  
  external_field :grade_level,             # External attribute 1
                 :age,                     # External attribute 2
                 :credits,                 # External attribute 3
                 :data,                    # Name of the association
                 class_name: "StudentData" # Class name of association
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
s = Student.create!
s.age
s.credits

s.age = 10
s.grade_level = 4
```

### Underscored accessors
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

This will allow you to use the external fields using undrescored methods:
```ruby
s = Student.create!
s._age
s._grade_level
```

### Original accessor

## Documentation

We have documentation on [RubyDoc](http://www.rubydoc.info/github/panorama-ed/rails_external_fields/master).

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

`RailsExternalFields` is released under the
[MIT License](https://github.com/panorama-ed/rails_external_fields/blob/master/LICENSE).
