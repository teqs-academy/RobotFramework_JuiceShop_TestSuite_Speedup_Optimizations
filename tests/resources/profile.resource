*** Settings ***
Documentation       Reusable keywords for the user profile page.

Resource            juice_shop.resource


*** Variables ***
${PROFILE_IMAGE_URL_INPUT_LOCATOR}      css=#url
${PROFILE_EMAIL_INPUT_LOCATOR}          css=#email
${PROFILE_USERNAME_INPUT_LOCATOR}       css=#username


*** Keywords ***
Open Profile Page
    [Documentation]    Open the user profile page through the account menu's email entry.
    Click    ${ACCOUNT_MENU_BUTTON_LOCATOR}
    Wait For Elements State    ${ACCOUNT_PROFILE_MENU_ITEM_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${ACCOUNT_PROFILE_MENU_ITEM_LOCATOR}
    Wait For Elements State    ${PROFILE_EMAIL_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Profile Page Should Be Displayed
    [Documentation]    Verify that the profile page is loaded at its own /profile URL and that
    ...    its Image URL, Email, and Username fields are visible.
    ${url}=    Get Url
    Should Contain    ${url}    /profile
    Wait For Elements State    ${PROFILE_IMAGE_URL_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Wait For Elements State    ${PROFILE_EMAIL_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Wait For Elements State    ${PROFILE_USERNAME_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Profile Email Field Should Show
    [Documentation]    Verify that the profile page's disabled Email field shows the given email.
    [Arguments]    ${expected_email}
    ${actual_email}=    Get Property    ${PROFILE_EMAIL_INPUT_LOCATOR}    value
    Should Be Equal As Strings    ${actual_email}    ${expected_email}
