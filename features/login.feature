Feature: Start a story

  Scenario: Not logged in
    Given I am at the Home Page
    When I follow "Start a Story"
    Then I should see an "email" text field

  Scenario: A citizen should see the tips/new page
    Given I am logged in as a citizen
    When I follow "Start a Story"
    Then I should see a tag of "h3" with "Create a Tip"

  Scenario: A reporter should see the pitches/new page
    Given I am logged in as a reporter
    When I follow "Start a Story"
    Then I should see a tag of "h3" with "Create a Pitch"
