Feature: Creating a blog post

  Scenario: A logged in reporter creating a valid post on my pitch
    Given I am logged in as a reporter
    And A pitch exists for the user
    And I am at the new blog post page for my pitch
    When I fill in "Title" with "My blog title"
    And I fill in "post[body]" with "Some blog text here. And here. And here"
    And I press "Save changes"
    Then I should see "Successfully created post"

  Scenario: A logged in reporter creating an invalid post on my pitch
    Given I am logged in as a reporter
    And A pitch exists for the user
    And I am at the new blog post page for my pitch
    When I fill in "Title" with ""
    And I fill in "post[body]" with ""
    And I press "Save changes"
    Then I should see "There was an error saving your post"

