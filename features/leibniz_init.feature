Feature: Add Leibniz testing to an existing project
  In order to get started with Leibniz
  As an infrastructure developer
  I want to run a command to initialize my project

  Scenario: Displaying help
    When I run `leibniz help init`
    Then the output should contain:
    """
    Usage:
      leibniz init
    """
    And the exit status should be 0

  @announce
  Scenario: Running leibniz init within a project
    When I run `leibniz init`
    Then the exit status should be 0
    And a directory named ".leibniz" should exist
    And a directory named "features/support" should exist
    And the file "features/support/env.rb" should contain "require 'leibniz'"
    And the file "features/learning_leibniz.feature" should contain:
    """
    Given I have provisioned the following infrastructure:
    """
    And a directory named "features/step_definitions" should exist
    And the file "features/step_definitions/learning_steps.rb" should contain "@infrastructure.converge"
    And the file ".gitignore" should contain ".leibniz/"
    And the file ".gitignore" should contain ".kitchen/"
