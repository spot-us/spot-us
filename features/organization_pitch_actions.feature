Feature: News Organizations Supporting Pitches

  Scenario: News Organization showing support for a pitch
    Given A pitch exists
    And I am logged in as a organization
    And I view the current pitch page
    When I follow "Show Support"
    Then I should see "Thanks"
    And I should not see "Show Support"

  Scenario: News Organization fully funding a pitch
    Given A pitch exists
    And I am logged in as a organization
    And I view the current pitch page
    When I follow "Fully Fund"
    Then I should be on the edit myspot::donation_amount page

  Scenario: News Organization half funding a pitch
    Given A pitch exists
    And I am logged in as a organization
    And I view the current pitch page
    When I follow "Half Fund"
    Then I should be on the edit myspot::donation_amount page
