# Leibniz

Leibniz is simple utility which provides the ability to launch
infrastructure using Test Kitchen, and run acceptance tests against
that infrastructure.  It is designed to be used as part of a set of
Cucumber / Gherkin features.

## Installation

Add this line to your application's Gemfile:

    gem 'leibniz'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install leibniz

## Usage

### Getting Started

Leibniz takes the view that acceptance testing of infrastructure
should be performed from the outside in, and make assertions from the
perspective of an external user consuming the delivered
infrastructure.

To get started, you will need to write some features and some steps.
Depending on how you build your infrastructure (at present the assumed
approach is Berkshelf and wrapper cookbooks, but there's no reason why
it wouldn't work with Librarian-chef, or some other approach).

#### Using Berkshelf

Assuming you have Berkshelf installed, you can use the in-built
cookbook generator to create your wrapper cookbook.  The alternative
is to create a cookbook directory, or use knife to create a cookbook,
and then add 'berkshelf' to a Gemfile, and run bundle install, followed by berks init.

Either way, once you have a cookbook which has been 'berksified' you
will have something that looks like this:

```
.
├── Berksfile
├── Gemfile
├── LICENSE
├── README.md
├── Thorfile
├── Vagrantfile
├── attributes
├── chefignore
├── definitions
├── files
│   └── default
├── libraries
├── metadata.rb
├── providers
├── recipes
│   └── default.rb
├── resources
└── templates
    └── default
```

Then

```
mkdir features
cd features
vi generic_webpage.feature
```

The feature you write needs to have a `Background` section like this:

```
Background:

  Given I have provisioned the following infrastructure:
  | Server Name     | Operating System | Version | Chef Version | Run List                 |
  | generic_webpage | ubuntu           |   12.04 |       11.8.0 | generic_webpage::default |
  And I have run Chef
```

These two steps can be satisfied by using Leibniz.  First, add Leibniz
to your Gemfile, and run `bundle install`.  Now create your step
definitions:

```
mkdir features/step_definitions
vi features/step_definitions/generic_webpage_steps.rb
``` 

The following steps will build and converge the infrastructure described in the table:

```
Given(/^I have provisioned the following infrastructure:$/) do |specification|
  @infrastructure = Leibniz.build(specification)
end

Given(/^I have run Chef$/) do
  @infrastructure.destroy
  @infrastructure.converge
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
