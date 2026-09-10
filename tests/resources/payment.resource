*** Settings ***
Documentation       Reusable keywords for navigating to and managing saved payment cards.

Resource            juice_shop.resource


*** Variables ***
${SAVED_PAYMENT_METHODS_LINK_LOCATOR}       css=button[aria-label="Go to saved payment methods page"]
${ADD_NEW_CARD_PANEL_LOCATOR}               text=Add new card
${CARD_NAME_INPUT_LOCATOR}                  css=mat-form-field:has-text("Name") input
${CARD_NUMBER_INPUT_LOCATOR}                css=mat-form-field:has-text("Card Number") input
${CARD_EXPIRY_MONTH_SELECT_LOCATOR}         css=mat-form-field:has-text("Expiry Month") select
${CARD_EXPIRY_YEAR_SELECT_LOCATOR}          css=mat-form-field:has-text("Expiry Year") select
${CARD_SUBMIT_BUTTON_LOCATOR}               css=#submitButton
${SAVED_CARD_NUMBER_LOCATOR}                css=mat-row >> nth=0 >> css=.mat-column-Number
${SAVED_CARD_NAME_LOCATOR}                  css=mat-row >> nth=0 >> css=.mat-column-Name
${SAVED_CARD_EXPIRY_LOCATOR}                css=mat-row >> nth=0 >> css=.mat-column-Expiry
${PAYMENT_CONTINUE_BUTTON_LOCATOR}          css=button[aria-label="Proceed to review"]


*** Keywords ***
Open Saved Payment Methods Page
    [Documentation]    Navigate to the saved payment methods page through the account menu.
    Open Orders And Payment Submenu
    Wait For Elements State    ${SAVED_PAYMENT_METHODS_LINK_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${SAVED_PAYMENT_METHODS_LINK_LOCATOR}
    Wait For Elements State    ${ADD_NEW_CARD_PANEL_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Empty Card Form Submission Should Be Disabled
    [Documentation]    Open the "Add new card" form and verify its submit button stays disabled
    ...    when no required fields have been filled in.
    Click    ${ADD_NEW_CARD_PANEL_LOCATOR}
    ${is_disabled}=    Get Property    ${CARD_SUBMIT_BUTTON_LOCATOR}    disabled
    Should Be True    ${is_disabled}

Add New Card
    [Documentation]    Add a new credit card.
    [Arguments]    &{card}
    Click    ${ADD_NEW_CARD_PANEL_LOCATOR}
    Fill Text    ${CARD_NAME_INPUT_LOCATOR}    ${card}[fullName]
    Fill Text    ${CARD_NUMBER_INPUT_LOCATOR}    ${card}[cardNum]
    Select Options By    ${CARD_EXPIRY_MONTH_SELECT_LOCATOR}    value    ${card}[expMonth]
    Select Options By    ${CARD_EXPIRY_YEAR_SELECT_LOCATOR}    value    ${card}[expYear]
    Click    ${CARD_SUBMIT_BUTTON_LOCATOR}

Saved Card Should Show
    [Documentation]    Navigate to the saved payment methods page and retry until the first row
    ...    matches the given masked number, name, and expiry.
    [Arguments]    ${masked_number}    ${full_name}    ${expiry}
    Open Saved Payment Methods Page
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Saved Card Should Show Exactly
    ...    ${masked_number}    ${full_name}    ${expiry}

Saved Card Should Show Exactly
    [Documentation]    Verify that the first saved-card row matches the given representation.
    [Arguments]    ${masked_number}    ${full_name}    ${expiry}
    ${number}=    Get Text    ${SAVED_CARD_NUMBER_LOCATOR}
    ${name}=    Get Text    ${SAVED_CARD_NAME_LOCATOR}
    ${expiry_text}=    Get Text    ${SAVED_CARD_EXPIRY_LOCATOR}
    Should Be Equal As Strings    ${number}    ${masked_number}    strip_spaces=True
    Should Be Equal As Strings    ${name}    ${full_name}    strip_spaces=True
    Should Be Equal As Strings    ${expiry_text}    ${expiry}    strip_spaces=True
