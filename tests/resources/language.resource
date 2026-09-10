*** Settings ***
Documentation       Reusable keywords for switching and verifying the shop's UI language.

Resource            juice_shop.resource


*** Variables ***
${LANGUAGE_BUTTON_LOCATOR}              css=#navbarLanguageButton
${LANGUAGE_BUTTON_CODE_LOCATOR}         css=#navbarLanguageButton .mdc-button__label
${LANGUAGE_OPTION_GERMAN_LOCATOR}       css=input[aria-label="Deutsch"]
${LANGUAGE_OPTION_ENGLISH_LOCATOR}      css=input[aria-label="English"]
${BASKET_LABEL_LOCATOR}                 css=.basket-label


*** Keywords ***
Switch Language To German
    [Documentation]    Open the language menu and select German.
    Click    ${LANGUAGE_BUTTON_LOCATOR}
    Wait For Elements State    ${LANGUAGE_OPTION_GERMAN_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${LANGUAGE_OPTION_GERMAN_LOCATOR}

Switch Language To English
    [Documentation]    Open the language menu and select English.
    Click    ${LANGUAGE_BUTTON_LOCATOR}
    Wait For Elements State    ${LANGUAGE_OPTION_ENGLISH_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${LANGUAGE_OPTION_ENGLISH_LOCATOR}

Language Button Should Show
    [Documentation]    Retry until the language button displays the expected language code.
    [Arguments]    ${expected_code}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Language Button Should Show Exactly    ${expected_code}

Language Button Should Show Exactly
    [Documentation]    Verify that the language button displays the expected language code.
    [Arguments]    ${expected_code}
    ${actual_code}=    Get Text    ${LANGUAGE_BUTTON_CODE_LOCATOR}
    Should Be Equal As Strings    ${actual_code}    ${expected_code}    strip_spaces=True

Basket Label Should Show
    [Documentation]    Retry until the basket nav label displays the expected translated text.
    [Arguments]    ${expected_text}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Label Should Show Exactly    ${expected_text}

Basket Label Should Show Exactly
    [Documentation]    Verify that the basket nav label displays the expected translated text.
    [Arguments]    ${expected_text}
    ${actual_text}=    Get Text    ${BASKET_LABEL_LOCATOR}
    Should Be Equal As Strings    ${actual_text}    ${expected_text}    strip_spaces=True
