Feature: Creating a pitch

  Scenario: A reporter creates a valid pitch
    Given I am logged in as a reporter
    And A sfbay network exists
    And A consumer protection topic exists
    And I visit the new pitch page
    When I select "Bay Area" from "network_select"
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
    And I press "Create a pitch"
    Then I should be on the show pitch page
    And I should see "Pitch was successfully created"
    And I should see "Pitch Headline"
    And I should see an "Edit This Pitch" titled link

  Scenario: A reporter creates an invalid pitch
    Given I am logged in as a reporter
    And I visit the new pitch page
    When I fill in "Your Pitch's Headline" with ""
    And I fill in "pitch[short_description]" with ""
    And I press "Create a pitch"
    Then I should be on the new pitch page
    And I should see "errors prohibited this pitch from being saved"
    And I should see "Headline can't be blank"
    And I should see "Short description can't be blank"
    And I should see "Contract agreement must be accepted"

  Scenario: A non-logged in user starts a story
    Given I am at the Home Page
    And I follow "Start a Story"
    And I login as a reporter
    Then I should be on the new pitch page

