## fixy

Library for generating fixed width in bytes flat file documents. 

## Installation


Add this line to your application's Gemfile:

```ruby
gem 'fixy'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install fixy
```

Then proceed to creating your records, and documents as described in the paragraphs below.

## Overview

A fixed-width document (`Fixy::Document`) is composed of multiple single-line records (`Fixy::Record`).

## Record definition

Every record is defined through a specific format, which defines the following aspects:

* Record length (how many bytes in the line)
* Required formatters (e.g. Alphanumeric, Rate, Amount)
* Field declaration:
	* Field human readable name
	* Field size (how many characters for the field)
	* Field range (start/end column for the field)
	* Field format (e.g. Alphanumeric, Rate, Amount)
* Field definition

Below is an example of a record for defining a person's first and last name:

```ruby
class PersonRecord < Fixy::Record

	# Include formatters
	
  include Fixy::Formatter::Alphanumeric

	# Define record length
	
  set_record_length 20

  # Fields Declaration:
  # -----------------------------------------------------------
  #       name          size      Range             Format        
  # ------------------------------------------------------------

  field :first_name,     10,     '1-10' ,      :alphanumeric
  field :last_name ,     10,     '11-20',      :alphanumeric

	# Any required data for the record can be 
	# provided through the initializer
			
	def initialize(first_name, last_name)
	  @first_name = first_name
	  @last_name  = last_name
	end
	
	# Fields Definition:
	# 1) Using a Proc 
	
  field_value :first_name, -> { @first_name }

	# 2) Using a method definition. 
	#    This is most interesting when complex logic is involved.
  
  def last_name
    @last_name
  end
end
```

Given a record definition, you can generate a single line (e.g. for testing purposes):

```ruby
PersonRecord.new('Sarah', 'Kerrigan').generate
	
# This will output the following 20 characters long record
#
#  "Sarah     Kerrigan  \n"
#
```

Most of the time however, you will not have to call `generate` directly, as the document will take care of that part.

## Document definition

A document is composed of a multitude of records (instances of a `Fixy::Record`). Because some document specification require earlier records to contain a count of upcoming records, both appending and prepending records is supported during a document definition. Below is an example of a document, based on the record defined in the previous section.

```ruby
class PeopleDocument < Fixy::Document
  def build
    append_record  PersonRecord.new('Sarah', 'Kerrigan')
    append_record  PersonRecord.new('Jim', 'Raynor')
    prepend_record PersonRecord.new('Arcturus', 'Mengsk')
  end
end
```

## Generating a document

With records and documents defined, generating documents is a breeze:

** Generating to string **

```ruby

PeopleDocument.new.generate
```

The output would be: "Arcturus  Mengsk    \nSarah     Kerrigan  \nJim       Raynor   "

** Generating to file **

```ruby

PeopleDocument.new.generate_to_file("output.txt")
```

** Generating HTML Debug version **

This is most useful when getting an error such as: `Unexpected character at line 20, column 95`. The HTML output makes it really easy to make sense out of any fixed width document, and quickly identify issues.

```ruby

PeopleDocument.new.generate_to_file("output.html", true)
```


## Creating custom formatters

Currently, there aren't many formatters included in this release, and you will most likely have to write your own. To create a new formatter of type `type` (e.g. amount), you simply need a method called `format_<type>(input, length)`. The argument `input` is the value being formatted, and `length` is the number of characters to fill. It is important to make sure `length` characters are returned by the formatter!

An example for formatter definition: 
```ruby

module Fixy
	module Formatter
		module Numeric
    		def format_numeric(input, length)
      			input = input.to_s
      			raise ArgumentError, "Invalid Input (only digits are accepted)" unless input =~ /^\d+$/
      			raise ArgumentError, "Not enough length (input: #{input}, length: #{length})" if input.length > length
      			input.rjust(length, '0')
           end
  		end
	end
end
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

