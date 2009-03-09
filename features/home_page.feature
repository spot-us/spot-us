Feature: Viewing the home page

  Scenario: Network navigation without subdomain
    Given A sfbay network exists
    And I am on the home page
    Then I should see "All Networks" not linked
    And I should see a "Bay Area" link

  Scenario: Network navigation on a subdomain
    Given A sfbay network exists
    And my current network is sfbay
    And I am at the "sfbay" network page
    Then I should see an "All Networks" link
    And I should see "Bay Area" not linked
