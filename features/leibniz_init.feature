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

  Scenario: Running leibniz init within a project
    When I run `leibniz init`
    Then the exit status should be 0
    And a directory named ".leibniz" should exist
    And a directory named "features/support" should exist
    And a directory named "features/step_definitions" should exist
    And the file ".gitignore" should contain ".leibniz/"
    