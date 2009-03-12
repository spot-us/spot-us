Feature: Action Buttons for a Tip

  Scenario: A non-logged in user viewing a tip
    Given A tip exists
    And I view the current tip page
    Then I should not see a form identified by "new_affiliation"
    And I should not see "Add this tip"

  Scenario: A logged in citizen viewing a tip
    Given A tip exists
    And I am logged in as a citizen
    And I view the current tip page
    Then I should not see a form identified by "new_affiliation"
    And I should not see "Add this tip"

  Scenario: A logged in reporter viewing a tip
    Given A tip exists
    And I am logged in as a reporter
    And A pitch exists for the user
    And I view the current tip page
    Then I should see a form identified by "new_affiliation"
    And I should see "Add this tip"

  Scenario: A logged in news organization viewing a tip
    Given A tip exists
    And I am logged in as a organization
    And I view the current tip page
    Then I should not see a form identified by "new_affiliation"
    And I should not see "Add this tip"
