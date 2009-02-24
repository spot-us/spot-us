Feature: Create a pitch

  Scenario: A reporter creates a pitch
    Given I am logged in as a "reporter"
    And A sfbay network exists
    And A consumer protection topic exists
    And I visit the new pitch page
    And I select "Bay Area" from "network_select"
    And I fill in "Your Pitch's Headline" with "Pitch Headline"
    And I fill in "pitch[short_description]" with "Lots of reasons!"
    And I check "pitch[topics_params][]"
    And I fill in "pitch[extended_description]" with "I can has helps?"
    And I fill in "pitch[skills]" with "I got skillz yo!"
    And I fill in "pitch[requested_amount]" with "1000"
    And I check "Text"
    And I fill in "pitch[delivery_description]" with "Some stuff to be delivered"
    And I fill in "pitch[featured_image_caption]" with "A caption"
    And I check "pitch[contract_agreement]"
    When I press "Create a pitch"
    Then I should be on the show pitch page
    