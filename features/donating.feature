Feature: Donating

  Scenario: New User
    Given A pitch exists
    And I view the current pitch page
    And I follow "Donate 20"
    And I follow "REGISTER HERE"
    And I fill in "Your First Name" with "My First Name"
    And I fill in "Your Last Name" with "My Last Name"
    And I fill in "Password" with "password"
    And I fill in "Confirm Password" with "password"
    And I fill in "Your E-mail Address" with "me@example.com"
    And I choose "Community Member"
    And I check "user_terms_of_service"
    And I press "Register"
    And I should see "Click the link in the email we just sent to you to finish creating your account!"
    When I activate my account with email "me@example.com"
    Then I should be on the edit myspot::donation_amounts page
    And I should see "20.00" inside a text field



