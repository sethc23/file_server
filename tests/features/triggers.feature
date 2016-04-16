
Feature: Verify pgSQL Triggers
    .


Scenario: Confirm Trigger When New Gmail Message is Added to DB

    Given   the "fs_update_es" trigger is loaded in pgsql
    When    a new gmail message is added to DB
    Then    "fs_update_es" should be triggered



