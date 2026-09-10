*** Settings ***
Documentation       Central Juice Shop locators and reusable UI interactions.

Library             String
Library             Browser
Resource            browser_setup.resource


*** Variables ***
${CATALOG_CARD_LOCATOR}                     css=mat-card:visible
${FIRST_CATALOG_CARD_LOCATOR}               css=mat-card:visible >> nth=0
${SEARCH_OPEN_BUTTON_LOCATOR}               css=button[aria-label*="Open search" i]
${SEARCH_INPUT_LOCATOR}                     css=app-mat-search-bar input:visible,
...                                         input[aria-label*="search" i]:visible,
...                                         input[placeholder*="Search" i]:visible,
...                                         input[type="search"]:visible
${NO_RESULTS_LOCATOR}                       text=No results found
${FIRST_PRODUCT_IMAGE_LOCATOR}              css=mat-card:visible img >> nth=0
${ADD_TO_BASKET_BUTTON_SELECTOR}            button[aria-label*="Add to Basket"], button[mattooltip*="Add to Basket"]
${FIRST_ADD_TO_BASKET_LOCATOR}              css=${ADD_TO_BASKET_BUTTON_SELECTOR} >> nth=0
${BASKET_BUTTON_LOCATOR}                    css=button[aria-label*="shopping cart"],
...                                         button[mattooltip*="Show the shopping cart"]
${BASKET_COUNT_LOCATOR}                     css=button[aria-label*="shopping cart"] .warn-notification
${BASKET_PAGE_TITLE_LOCATOR}                css=app-basket h1
${BASKET_TOTAL_PRICE_LOCATOR}               css=#price
${PRODUCT_DETAILS_DIALOG_LOCATOR}           css=mat-dialog-container
${PRODUCT_DETAILS_CLOSE_LOCATOR}            css=mat-dialog-container button[aria-label*="Close"],
...                                         mat-dialog-container button[mat-dialog-close]
${ACCOUNT_MENU_BUTTON_LOCATOR}              css=#navbarAccount
${LOGIN_BUTTON_LOCATOR}                     css=#navbarLoginButton
${LOGOUT_BUTTON_LOCATOR}                    css=#navbarLogoutButton
${ORDERS_PAYMENT_MENU_BUTTON_LOCATOR}       css=button[aria-label="Show Orders and Payment Menu"]
${ACCOUNT_PROFILE_MENU_ITEM_LOCATOR}        css=button[aria-label="Go to user profile"]
${ACCOUNT_PROFILE_EMAIL_LOCATOR}            ${ACCOUNT_PROFILE_MENU_ITEM_LOCATOR} .mat-mdc-menu-item-text
${HOME_BUTTON_LOCATOR}                      css=button[aria-label="Back to homepage"]
${SELECTION_ROW_PREFIX_LOCATOR}             css=mat-row
${FIRST_SELECTION_ROW_RADIO_LOCATOR}        ${SELECTION_ROW_PREFIX_LOCATOR} >> nth=0 >> css=input[type="radio"]


*** Keywords ***
Open Shop Homepage
    [Documentation]    Open the shop homepage, dismiss startup dialogs, and wait for the catalog to load.
    Open Browser To Shop
    Dismiss Startup Dialogs
    Wait Until Shop Catalog Loads

Open Shop Page In Shared Browser
    [Documentation]    Open a fresh page in the shared browser and wait for the shop to be ready.
    New Page    ${BASE_URL}
    Dismiss Startup Dialogs
    Wait Until Shop Catalog Loads

Close Current Shop Page
    [Documentation]    Capture a failure screenshot if needed and close the current page so the
    ...    next test starts from a clean browser state.
    Run Keyword If Test Failed    Take Screenshot
    Run Keyword And Ignore Error    Close Page

Close Shared Browser
    [Documentation]    Close the shared browser after the login suite is finished.
    Run Keyword And Ignore Error    Close Browser

Wait Until Shop Catalog Loads
    [Documentation]    Wait until the first visible catalog card is rendered.
    Wait For Elements State    ${FIRST_CATALOG_CARD_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Dismiss Startup Dialogs
    [Documentation]    Dismiss the welcome and cookie dialogs when they are shown.
    Click If Visible    text=Dismiss
    Click If Visible    text=Me want it!

Search For Product
    [Documentation]    Search the catalog for the provided term and wait for the matching result state.
    [Arguments]    ${search_term}
    Ensure Search Input Is Ready
    Type Text    ${SEARCH_INPUT_LOCATOR}    ${search_term}
    Press Keys    ${SEARCH_INPUT_LOCATOR}    Enter
    Wait For Search State    ${search_term}

Wait For Search State
    [Documentation]    Wait for the catalog heading that corresponds to the current search input state.
    [Arguments]    ${search_term}
    ${normalized_search_term}=    Strip String    ${search_term}
    IF    $search_term == ''
        Wait Until Shop Catalog Loads
    ELSE IF    $normalized_search_term == ''
        Wait For Elements State    text=Search Results -    visible    ${BROWSER_TIMEOUT}
    ELSE
        Wait For Elements State    text=Search Results - ${normalized_search_term}    visible    ${BROWSER_TIMEOUT}
    END

Search Results Should Match
    [Documentation]    Search for a term and verify that the visible result count matches the expectation.
    [Arguments]    ${search_term}
    ...    ${expected_result_count}
    ${expected_count}=    Convert To Integer    ${expected_result_count}
    Search For Product    ${search_term}
    IF    $expected_count == 0
        Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
        ...    No Results Message Should Be Visible
    ELSE
        Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
        ...    Catalog Should Show Exact Product Count    ${expected_count}
    END

Ensure Search Input Is Ready
    [Documentation]    Open the search UI when needed and wait until the input field is visible.
    Click If Visible    ${SEARCH_OPEN_BUTTON_LOCATOR}
    Wait For Elements State    ${SEARCH_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Open First Product Details
    [Documentation]    Open the details dialog for the first visible product card.
    Wait For Elements State    ${FIRST_PRODUCT_IMAGE_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${FIRST_PRODUCT_IMAGE_LOCATOR}
    Wait For Elements State    ${PRODUCT_DETAILS_DIALOG_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Close Product Details
    [Documentation]    Close the visible product details dialog if it is open.
    Click If Visible    ${PRODUCT_DETAILS_CLOSE_LOCATOR}

Open Orders And Payment Submenu
    [Documentation]    Open the account menu and its Orders & Payment submenu.
    Click    ${ACCOUNT_MENU_BUTTON_LOCATOR}
    Wait For Elements State    ${ORDERS_PAYMENT_MENU_BUTTON_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${ORDERS_PAYMENT_MENU_BUTTON_LOCATOR}

Account Menu Should Show Email
    [Documentation]    Open the account menu and retry until its profile entry shows the given
    ...    email. This can take a short while, because of the asynchronous whoAmI call.
    [Arguments]    ${expected_email}
    Click    ${ACCOUNT_MENU_BUTTON_LOCATOR}
    Wait For Elements State    ${ACCOUNT_PROFILE_EMAIL_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Account Menu Should Show Email Exactly    ${expected_email}

Account Menu Should Show Email Exactly
    [Documentation]    Verify that the account menu's profile entry shows the given email.
    [Arguments]    ${expected_email}
    ${actual_email}=    Get Text    ${ACCOUNT_PROFILE_EMAIL_LOCATOR}
    Should Be Equal As Strings    ${actual_email}    ${expected_email}    strip_spaces=True

Add First Visible Product To Basket
    [Documentation]    Add the first visible product to the basket and wait for the counter to increase.
    Wait For Elements State    ${FIRST_ADD_TO_BASKET_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    ${before}=    Read Basket Count
    Click    ${FIRST_ADD_TO_BASKET_LOCATOR}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Count Should Be Greater Than    ${before}

Add Named Product To Basket
    [Documentation]    Add the visible catalog product matching the exact given name to the
    ...    basket and wait for the counter to increase.
    [Arguments]    ${product_name}
    VAR    ${card_locator}=    css=mat-card:visible:has(.name:text-is("${product_name}"))
    Wait For Elements State    ${card_locator}    visible    ${BROWSER_TIMEOUT}
    ${before}=    Read Basket Count
    Click    ${card_locator} >> css=${ADD_TO_BASKET_BUTTON_SELECTOR}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Count Should Be Greater Than    ${before}

Open Basket
    [Documentation]    Open the basket page and wait until its title is visible.
    Click    ${BASKET_BUTTON_LOCATOR}
    Wait For Elements State    ${BASKET_PAGE_TITLE_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Read Basket Count
    [Documentation]    Return the visible basket counter value or zero when no counter is shown.
    ${counter_count}=    Get Element Count    ${BASKET_COUNT_LOCATOR}
    IF    $counter_count == 0    RETURN    0
    ${count_text}=    Get Text    ${BASKET_COUNT_LOCATOR}
    ${normalized_count}=    Strip String    ${count_text}
    ${count}=    Convert To Integer    ${normalized_count}
    RETURN    ${count}

Basket Count Should Be Greater Than
    [Documentation]    Verify that the current basket count is greater than the provided baseline.
    [Arguments]    ${baseline}
    ${current}=    Read Basket Count
    ${current_int}=    Convert To Integer    ${current}
    ${baseline_int}=    Convert To Integer    ${baseline}
    Should Be True    ${current_int} > ${baseline_int}

Basket Count Should Be Less Than
    [Documentation]    Verify that the current basket count is less than the provided baseline.
    [Arguments]    ${baseline}
    ${current}=    Read Basket Count
    ${current_int}=    Convert To Integer    ${current}
    ${baseline_int}=    Convert To Integer    ${baseline}
    Should Be True    ${current_int} < ${baseline_int}

Catalog Should Show Products
    [Documentation]    Verify that at least one visible catalog card is present.
    ${cards}=    Get Element Count    ${CATALOG_CARD_LOCATOR}
    Should Be True    ${cards} >= 1

Catalog Should Show Exact Product Count
    [Documentation]    Verify that the visible catalog card count matches the expected value.
    [Arguments]    ${expected_count}
    ${cards}=    Get Element Count    ${CATALOG_CARD_LOCATOR}
    Should Be Equal As Integers    ${cards}    ${expected_count}

No Results Message Should Be Visible
    [Documentation]    Wait until the no-results message is visible.
    Wait For Elements State    ${NO_RESULTS_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Details Dialog Should Be Visible
    [Documentation]    Wait until the product details dialog is visible.
    Wait For Elements State    ${PRODUCT_DETAILS_DIALOG_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Click If Visible
    [Documentation]    Click the locator with force enabled when it becomes visible within one second.
    [Arguments]    ${locator}
    ${is_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${locator}    visible    1s
    IF    ${is_visible}    Click With Options    ${locator}    force=True

Row Locator At Index
    [Documentation]    Build a locator for the row at the given index within a row-prefix
    ...    locator, scoped to the given CSS column/child selector.
    [Arguments]    ${row_prefix_locator}    ${row_index}    ${css_suffix}
    RETURN    ${row_prefix_locator} >> nth=${row_index} >> css=${css_suffix}

Selection Row Radio Locator
    [Documentation]    Build the radio-button locator for the selection row at the given index.
    ...    Used by any flow that reuses the shared saved-address/saved-card selection table,
    ...    such as checkout and the wallet deposit flow.
    [Arguments]    ${row_index}
    ${locator}=    Row Locator At Index    ${SELECTION_ROW_PREFIX_LOCATOR}    ${row_index}    input[type="radio"]
    RETURN    ${locator}

Parse Price Text To Cents
    [Documentation]    Extract a decimal price from UI text and convert it to cents.
    [Arguments]    ${price_text}
    ${matches}=    Get Regexp Matches    ${price_text}    (\\d+[\\.,]\\d+|\\d+)    1
    Should Not Be Empty    ${matches}
    ${normalized}=    Replace String    ${matches}[0]    ,    .
    ${price_cents}=    Evaluate    int(round(float($normalized) * 100))
    RETURN    ${price_cents}

Go To Homepage Via Banner
    [Documentation]    Click the navbar banner/logo and wait for the catalog to reload.
    Click    ${HOME_BUTTON_LOCATOR}
    Wait Until Shop Catalog Loads
