*** Settings ***
Documentation       Reusable keywords for navigating to and managing saved addresses.

Resource            juice_shop.resource


*** Variables ***
${SAVED_ADDRESSES_LINK_LOCATOR}             css=button[aria-label="Go to saved address page"]
${ADD_NEW_ADDRESS_BUTTON_LOCATOR}           css=button[aria-label="Add a new address"]
${ADDRESS_COUNTRY_INPUT_LOCATOR}            css=input[placeholder="Please provide a country."]
${ADDRESS_NAME_INPUT_LOCATOR}               css=input[placeholder="Please provide a name."]
${ADDRESS_MOBILE_NUMBER_INPUT_LOCATOR}      css=input[placeholder="Please provide a mobile number."]
${ADDRESS_ZIP_CODE_INPUT_LOCATOR}           css=input[placeholder="Please provide a ZIP code."]
${ADDRESS_STREET_INPUT_LOCATOR}             css=#address
${ADDRESS_CITY_INPUT_LOCATOR}               css=input[placeholder="Please provide a city."]
${ADDRESS_STATE_INPUT_LOCATOR}              css=input[placeholder="Please provide a state."]
${ADDRESS_SUBMIT_BUTTON_LOCATOR}            css=#submitButton
${SAVED_ADDRESS_NAME_LOCATOR}               css=mat-row >> nth=0 >> css=.mat-column-Name
${SAVED_ADDRESS_ADDRESS_LOCATOR}            css=mat-row >> nth=0 >> css=.mat-column-Address
${SAVED_ADDRESS_COUNTRY_LOCATOR}            css=mat-row >> nth=0 >> css=.mat-column-Country


*** Keywords ***
Open Saved Addresses Page
    [Documentation]    Navigate to the saved-addresses page through the account menu.
    Open Orders And Payment Submenu
    Wait For Elements State    ${SAVED_ADDRESSES_LINK_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${SAVED_ADDRESSES_LINK_LOCATOR}
    Wait For Elements State    ${ADD_NEW_ADDRESS_BUTTON_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Empty Address Form Submission Should Be Disabled
    [Documentation]    Open the "Add New Address" form and verify its submit button stays
    ...    disabled when no required fields have been filled in.
    Click    ${ADD_NEW_ADDRESS_BUTTON_LOCATOR}
    ${is_disabled}=    Get Property    ${ADDRESS_SUBMIT_BUTTON_LOCATOR}    disabled
    Should Be True    ${is_disabled}

Add New Address
    [Documentation]    Fill and submit the "Add New Address" form.
    [Arguments]    &{address}
    Click    ${ADD_NEW_ADDRESS_BUTTON_LOCATOR}
    Fill Text    ${ADDRESS_COUNTRY_INPUT_LOCATOR}    ${address}[country]
    Fill Text    ${ADDRESS_NAME_INPUT_LOCATOR}    ${address}[fullName]
    Fill Text    ${ADDRESS_MOBILE_NUMBER_INPUT_LOCATOR}    ${address}[mobileNum]
    Fill Text    ${ADDRESS_ZIP_CODE_INPUT_LOCATOR}    ${address}[zipCode]
    Fill Text    ${ADDRESS_STREET_INPUT_LOCATOR}    ${address}[streetAddress]
    Fill Text    ${ADDRESS_CITY_INPUT_LOCATOR}    ${address}[city]
    Fill Text    ${ADDRESS_STATE_INPUT_LOCATOR}    ${address}[state]
    Click    ${ADDRESS_SUBMIT_BUTTON_LOCATOR}
    Wait Until Shop Catalog Loads

Saved Address Should Show
    [Documentation]    Navigate to the saved-addresses page and retry until the first row matches
    ...    the given representation.
    [Arguments]    ${full_name}    ${expected_address_text}    ${country}
    Open Saved Addresses Page
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Saved Address Should Show Exactly
    ...    ${full_name}    ${expected_address_text}    ${country}

Saved Address Should Show Exactly
    [Documentation]    Verify that the first saved-address row matches the given representation.
    [Arguments]    ${full_name}    ${expected_address_text}    ${country}
    ${name}=    Get Text    ${SAVED_ADDRESS_NAME_LOCATOR}
    ${address}=    Get Text    ${SAVED_ADDRESS_ADDRESS_LOCATOR}
    ${country_text}=    Get Text    ${SAVED_ADDRESS_COUNTRY_LOCATOR}
    Should Be Equal As Strings    ${name}    ${full_name}    strip_spaces=True
    Should Be Equal As Strings    ${address}    ${expected_address_text}    strip_spaces=True
    Should Be Equal As Strings    ${country_text}    ${country}    strip_spaces=True
