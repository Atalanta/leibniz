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

#### Writing your first feature

We are going to take you through the process of iterating on the creation of a feature and its step definitions. In reality you might merge some of these steps together and not run cucumber as often as we do here, but this illustrates every step in the process.

First we need to create a directory to contain our features, then write our first feature:

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

This background section is responsible for provisioning infrastructure and getting it into a state whereupon we can run some acceptance tests against it.  The title of each column is defined by Leibiniz:

- `Server Name`  - this is the name of the machine you will be provisioning.  Leibniz will prepend `leibniz` to the name and will launch a machine with this name.
- `Operating System` - this translates to the base OS of a Vagrant box which is downloaded on demand.  The boxes used are Opscode's 'Bento' boxes, and have nothing other than a base OS installed.  At present `ubuntu`, `debian`, `centos` and `fedora` are supported.
- `Version` - this is version of the Operating System.  See the Bento website for an up-to-date specification of the available versions.
- `Chef Version` - this is the version of the Chef 'client' software to be installed.
- `Run List` - this is the Chef run list which will be used when the node is converged.

These two steps are satisfied by Leibniz.  We need to ensure the Leibniz library is available to Chef.  To do this, add `leibniz` to your Gemfile, and run `bundle install`.  Then create a `support` directory under your `features` directory, and within the `support` directory, create an `env.rb` file.  This should read:

```
require 'leibniz'
```

Now create your step definitions:

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

At present, Leibniz only knows how to provision infrastructure using
the Vagrant driver.  By default this will assume you have Virtualbox
on the system where you are running Cucumber.  A top priority is to
support other Kitchen drivers, which will enable infrastructure to be
provisioned on cloud platforms, via LXC or Docker, or just with
Vagrant.

Once you have your feature, env.rb and steps in place, you can run
`cucumber`.  This will build the infrastructure you described using
Chef.

You may find it useful to tail the logs during this process:

```
tail -f .kitchen/logs/leibniz-generic-webpage.log
```

If all goes well, you should see something like:

```
Feature: Serve a generic webpage

  In order to demonstrate how Leibniz works
  As an infrastructure developer
  I want to be able to serve a generic webpage and test it

  Background:                                              # features/crap_webpage.feature:7
    Given I have provisioned the following infrastructure: # features/step_definitions/generic_webpage_steps.rb:1
      | Server Name     | Operating System | Version | Chef Version | Run List                 |
      | generic_webpage | ubuntu           | 12.04   | 11.8.0       | generic_webpage::default |
Using generic_webpage (0.1.0) from metadata
    And I have run Chef                                    # features/step_definitions/generic_webpage_steps.rb:5

0 scenarios
2 steps (2 passed)
0m58.613s
```

At this stage we have only provisioned the machine per the table we provided in the feature.  We now need to describe an example of what the infrastructure does.  Open the feature and add an example:

```
  Scenario: Infrastructure developer can see generic webpage
    Given a URL "http://generic-webpage.com"
    When I browse to the URL
    Then I should see "This is a generic webpage"
```

When we run cucumber again, we should be told that our steps are undefined. Cucumber will suggest some snippets we can use:

```
You can implement step definitions for undefined steps with these snippets:

Given(/^a URL "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

When(/^I browse to the URL$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
```
Copy and paste these into `features/step_definitions/generic_webpage_steps.rb`, then run cucumber again.  We should now see that the step runs, but is marked as pending - that is we haven't implemented the acceptance test.

The idea of Leibniz is to make the provisioning and converging of infrastructure nodes as painless and flexible as possible, enabling the infrastructure developer to dive into writing the acceptance tests right away.  Future versions of the library may ship some useful features to help with common acceptance test types.

We now need to write the implementation of our acceptance tests:

- Given a URL "http://generic-webpage.com"
- When I browse to the URL
- Then I should see "This is a generic webpage"

The first step simply requires us to capture a host header that we can use as part of an http client:

```
Given(/^a URL "(.*?)"$/) do |url|
  @host_header = url.split("/").last
end
```

The second step requires us to use an http client. There are many options available for this, Faraday is a simple one:

```
When(/^I browse to the URL$/) do
  connection = Faraday.new(url: "http://#{@infrastructure['generic-webpage'].ip}", headers: { 'Host' => @host_header }) do |faraday|
    faraday.adapter Faraday.default_adapter
  end
  @page = connection.get('/').body
end
```

Note: the ip of the infrastructure we have built is available as part of the @infrastructure object returned by Leibniz.

The final step is a simple rspec expectation:

```
Then(/^I should see "(.*?)"$/) do |content|
  expect (@page).to match /#{content}/
end
```

When we run cucumber this time, the tests will fail because we've not implemented anything to actually serve a website, nor have we deployed the website for the web server to serve.

Making the tests pass (i.e. writing the Chef code to deploy a web server and serve a static web page) is left as an exercise for the reader. One the code is written, running cucumber again will converge the node and run the acceptance tests, resulting in the tests passing, like this:

```
Feature: Serve a generic webpage

  In order to demonstrate how Leibniz works
  As an infrastructure developer
  I want to be able to serve a generic webpage and test it

  Background:                                              # features/generic_webpage.feature:7
    Given I have provisioned the following infrastructure: # features/step_definitions/generic_webpage_steps.rb:3
      | Server Name     | Operating System | Version | Chef Version | Run List                 |
      | generic_webpage | ubuntu           | 12.04   | 11.8.0       | generic_webpage::default |
Using generic_webpage (0.1.0)
Using apt (2.3.0)
Using apache2 (1.8.4)
    And I have run Chef                                    # features/step_definitions/generic_webpage_steps.rb:7

  Scenario: Infrastructure developer can see generic webpage # features/generic_webpage.feature:14
    Given a URL "http://generic-webpage.com"                 # features/step_definitions/generic_webpage_steps.rb:12
    When I browse to the URL                                 # features/step_definitions/generic_webpage_steps.rb:16
    Then I should see "This is a generic webpage"            # features/step_definitions/generic_webpage_steps.rb:23

1 scenario (1 passed)
5 steps (5 passed)
1m25.227s
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
