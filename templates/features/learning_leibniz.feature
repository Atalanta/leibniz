Feature: Learn to use Leibniz

  In order to learn how to use Leibniz
  As an infrastructure developer
  I want to be able to have a skeleton feature

  Background:

    Given I have provisioned the following infrastructure:
    | Server Name     | Operating System | Version | Chef Version | Run List          |
    | learning        | centos           | 6.4     |       11.8.0 | learning::default |
    And I have run Chef
    
    Scenario: Infrastructure developer can learn Leibniz
      pending
      # Write your features here!