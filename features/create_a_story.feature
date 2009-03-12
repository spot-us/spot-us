Feature: Create a story from a pitch

Scenario: A reporter creates a story from a pitch
  Given I am logged in as a reporter
  And I have created a "pitch"
  And I call the approve transition on the current pitch
  And A donation exists for the pitch
  And I visit the myspot pitches page
  And I follow "Accept"
  When I follow "Report"
  Then I should be on the edit story page
