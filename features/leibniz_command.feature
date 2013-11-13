Feature: A command line interface for Leibniz 
  In order to simplify the process of getting started with Leibniz Acceptance Testing 
  As a Leibniz user
  I want a command line interface that has sane defaults and built in help

  Scenario: Displaying help
    When I run `leibniz help`
    Then the exit status should be 0
    And the output should contain "leibniz init"
    And the output should contain "leibniz version"

  Scenario: Displaying the version of Leibniz 
    When I run `leibniz version`
    Then the exit status should be 0
    And the output should contain "Leibniz version"
