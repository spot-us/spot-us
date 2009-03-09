Feature: Create a network

  Scenario: An admin creates an sfbay network
    Given I am logged in as a admin
    And I visit the new admin network page
    And I fill in "Name" with "sfbay"
    And I fill in "Display Name" with "Bay Area"
    And I press "Save changes"
    Then I should see an "All networks" link

  Scenario: An admin tries to create an invalid network
    Given I am logged in as a admin
    And I visit the new admin network page
    And I fill in "Name" with ""
    And I fill in "Display Name" with ""
    And I press "Save changes"
    Then I should see "errors prohibited this network from being saved"

