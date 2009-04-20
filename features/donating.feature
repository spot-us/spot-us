Feature: Donating

  Scenario: Existing User Donating 20
    Given a pitch
    And I am logged in as a citizen
    And I view the current pitch page
    When I press "Donate 20"
    Then I should be on the edit myspot::donation_amounts page
    And I should see "20.00" inside a text field

  Scenario: Existing User Donating Variable Amount
    Given a pitch
    And I am logged in as a citizen
    And I view the current pitch page
    And I fill in "Donate other amount" with "50.00"
    When I press "Donate another amount"
    Then I should be on the edit myspot::donation_amounts page
    And I should see "50.00" inside a text field
