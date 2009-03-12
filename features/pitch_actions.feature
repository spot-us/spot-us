Feature: Action Buttons for a Pitch

  Scenario: A non-logged in user viewing a pitch
    Given A pitch exists
    And I view the current pitch page
    Then I should not see a "Show Support" titled link
    And I should not see a "Fully Fund" titled link
    And I should not see a "Half Fund" titled link
    And I should see a "Join Reporting Team" titled link

  Scenario: A logged in citizen viewing a pitch
    Given A pitch exists
    And I am logged in as a citizen
    And I view the current pitch page
    Then I should not see a "Show Support" titled link
    And I should not see a "Fully Fund" titled link
    And I should not see a "Half Fund" titled link
    And I should see a "Join Reporting Team" titled link
    And I should not see a "Make Blog Post" titled link

  Scenario: A logged in reporter viewing my own pitch
    Given I am logged in as a reporter
    And A pitch exists for the user
    And I view the current pitch page
    Then I should not see a "Show Support" titled link
    And I should not see a "Fully Fund" titled link
    And I should not see a "Half Fund" titled link
    And I should not see an "Join Reporting Team" titled link
    And I should see a "Make Blog Post" titled link

  Scenario: A logged in reporter viewing a pitch
    Given A pitch exists
    And I am logged in as a reporter
    And I view the current pitch page
    Then I should not see a "Show Support" titled link
    And I should not see a "Fully Fund" titled link
    And I should not see a "Half Fund" titled link
    And I should see an "Join Reporting Team" titled link
    And I should not see a "Make Blog Post" titled link

  Scenario: A logged in news organization viewing a pitch
    Given A pitch exists
    And I am logged in as a organization
    And I view the current pitch page
    Then I should see a "Show Support" titled link
    And I should see a "Fully Fund" titled link
    And I should see a "Half Fund" titled link
    And I should see a "Join Reporting Team" titled link
    And I should not see a "Make Blog Post" titled link
