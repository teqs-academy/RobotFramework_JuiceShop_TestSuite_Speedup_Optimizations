*** Settings ***
Documentation       Reusable basket UI actions and assertions for the Juice Shop demo.

Library             String
Resource            juice_shop.resource
Resource            authenticated_browser.resource


*** Variables ***
${FIRST_BASKET_ITEM_PRODUCT_LOCATOR}            css=mat-row >> nth=0 >> css=.cdk-column-product
${FIRST_BASKET_ITEM_QUANTITY_LOCATOR}           css=mat-row >> nth=0 >> css=.cdk-column-quantity span.cell-initial-font
${FIRST_BASKET_ITEM_PRICE_LOCATOR}              css=mat-row >> nth=0 >> css=.cdk-column-price
${FIRST_BASKET_ITEM_MINUS_BUTTON_LOCATOR}       css=mat-row >> nth=0 >> css=.cdk-column-quantity button >> nth=0
${FIRST_BASKET_ITEM_PLUS_BUTTON_LOCATOR}        css=mat-row >> nth=0 >> css=.cdk-column-quantity button >> nth=1
${FIRST_BASKET_ITEM_REMOVE_BUTTON_LOCATOR}      css=mat-row >> nth=0 >> css=.cdk-column-remove button
${BASKET_ROW_PREFIX_LOCATOR}                    css=mat-row
${BASKET_ITEM_ROW_LOCATOR}                      css=app-basket mat-row
${BASKET_SNACKBAR_CLOSE_LOCATOR}                css=mat-snack-bar-container button:has-text("X"),
...                                             simple-snack-bar button:has-text("X")


*** Keywords ***
Add First Visible Product To Basket Multiple Times
    [Documentation]    Add the first visible catalog product to the basket the requested number of times.
    [Arguments]    ${count}
    ${times}=    Convert To Integer    ${count}
    FOR    ${_}    IN RANGE    ${times}
        Add First Visible Product To Basket
        Close Basket Snackbar If Present
    END

Basket Title Should Show Owner
    [Documentation]    Retry until the basket page title includes the expected owner label. A
    ...    retry is needed because the title resolves the owner through an asynchronous
    ...    whoAmI call that briefly shows "(anonymous)" while it is still in flight.
    [Arguments]    ${owner_text}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Title Should Show Owner Exactly    ${owner_text}

Basket Title Should Show Owner Exactly
    [Documentation]    Verify that the basket page title includes the expected owner label.
    [Arguments]    ${owner_text}
    ${title}=    Get Text    ${BASKET_PAGE_TITLE_LOCATOR}
    Should Contain    ${title}    ${owner_text}

Basket Should Be Empty
    [Documentation]    Verify that the basket shows no rows, no count, and no total price.
    Basket Page Should Be Visible
    ${rows}=    Get Element Count    ${BASKET_ITEM_ROW_LOCATOR}
    Should Be Equal As Integers    ${rows}    0
    Basket Count Should Be    0
    Basket Total Price Should Be In Cents    0

Basket Page Should Be Visible
    [Documentation]    Wait until the basket page header and total price are both visible.
    Wait For Elements State    ${BASKET_PAGE_TITLE_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Wait For Elements State    ${BASKET_TOTAL_PRICE_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Basket Count Should Be
    [Documentation]    Retry until the basket counter matches the expected quantity.
    [Arguments]    ${expected_count}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Count Should Be Exactly    ${expected_count}

Basket Count Should Be Exactly
    [Documentation]    Verify that the basket counter exactly matches the expected quantity.
    [Arguments]    ${expected_count}
    ${actual_count}=    Read Basket Count
    Should Be Equal As Integers    ${actual_count}    ${expected_count}

Basket Should Show Product Quantity
    [Documentation]    Retry until the first basket row shows the expected product quantity.
    [Arguments]    ${expected_quantity}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Quantity Should Be Exactly    ${expected_quantity}

Basket Quantity Should Be Exactly
    [Documentation]    Verify that the first basket row shows the expected product quantity.
    [Arguments]    ${expected_quantity}
    ${actual_quantity}=    Read First Basket Item Quantity
    Should Be Equal As Integers    ${actual_quantity}    ${expected_quantity}

Basket Total Price Should Match Visible Item Price
    [Documentation]    Verify that the basket total equals the visible item quantity multiplied by its unit price.
    ${quantity}=    Read First Basket Item Quantity
    ${unit_price}=    Read First Basket Item Price In Cents
    ${expected_total}=    Evaluate    int($quantity) * int($unit_price)
    Basket Total Price Should Be In Cents    ${expected_total}

Basket Total Price Should Be In Cents
    [Documentation]    Retry until the basket total matches the expected value in cents.
    [Arguments]    ${expected_total}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Total Price Should Be Exactly In Cents    ${expected_total}

Basket Total Price Should Be Exactly In Cents
    [Documentation]    Verify that the basket total exactly matches the expected value in cents.
    [Arguments]    ${expected_total}
    ${actual_total}=    Read Basket Total Price In Cents
    Should Be Equal As Integers    ${actual_total}    ${expected_total}

Basket Total Price Should Increase By
    [Documentation]    Verify that the basket total increased by the expected amount in cents.
    [Arguments]    ${before_total}
    ...    ${increase_amount}
    ${expected_total}=    Evaluate    int($before_total) + int($increase_amount)
    Basket Total Price Should Be In Cents    ${expected_total}

Prepare Logged In Basket With One Product
    [Documentation]    Authenticate a disposable account through the API on the current page,
    ...    add one product, open the basket page, and return the email.
    ${email}=    Sign In Current Page Via Api
    Search For Product    ${SEARCH_TERM}
    Add First Visible Product To Basket
    Close Basket Snackbar If Present
    Open Basket
    RETURN    ${email}

Increase First Basket Item Quantity By One
    [Documentation]    Increase the first basket row quantity by one and wait for the updated quantity.
    ${before_quantity}=    Read First Basket Item Quantity
    Click    ${FIRST_BASKET_ITEM_PLUS_BUTTON_LOCATOR}
    ${expected_quantity}=    Evaluate    int($before_quantity) + 1
    Basket Should Show Product Quantity    ${expected_quantity}

Decrease First Basket Item Quantity By One
    [Documentation]    Decrease the first basket row quantity by one and wait for the updated quantity.
    ${before_quantity}=    Read First Basket Item Quantity
    Click    ${FIRST_BASKET_ITEM_MINUS_BUTTON_LOCATOR}
    ${expected_quantity}=    Evaluate    int($before_quantity) - 1
    Basket Should Show Product Quantity    ${expected_quantity}

Remove First Basket Item
    [Documentation]    Remove the first basket row entirely and wait for the basket count to drop.
    ${before}=    Read Basket Count
    Click    ${FIRST_BASKET_ITEM_REMOVE_BUTTON_LOCATOR}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Count Should Be Less Than    ${before}

Read First Basket Item Name
    [Documentation]    Return the visible product name for the first basket row.
    ${name_text}=    Get Text    ${FIRST_BASKET_ITEM_PRODUCT_LOCATOR}
    ${name}=    Strip String    ${name_text}
    RETURN    ${name}

Read First Basket Item Quantity
    [Documentation]    Return the visible quantity value for the first basket row.
    ${quantity_text}=    Get Text    ${FIRST_BASKET_ITEM_QUANTITY_LOCATOR}
    ${quantity}=    Strip String    ${quantity_text}
    RETURN    ${quantity}

Read First Basket Item Price In Cents
    [Documentation]    Return the first basket row unit price as an integer number of cents.
    ${price_text}=    Get Text    ${FIRST_BASKET_ITEM_PRICE_LOCATOR}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    RETURN    ${price_cents}

Basket Row Price Locator
    [Documentation]    Build the price-cell locator for the basket row at the given index.
    [Arguments]    ${row_index}
    ${locator}=    Row Locator At Index    ${BASKET_ROW_PREFIX_LOCATOR}    ${row_index}    .cdk-column-price
    RETURN    ${locator}

Read Basket Item Price At Row In Cents
    [Documentation]    Return the unit price for the basket row at the given index, in cents.
    [Arguments]    ${row_index}
    ${locator}=    Basket Row Price Locator    ${row_index}
    ${price_text}=    Get Text    ${locator}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    RETURN    ${price_cents}

Read Basket Total Price In Cents
    [Documentation]    Return the basket total price as an integer number of cents.
    ${price_text}=    Get Text    ${BASKET_TOTAL_PRICE_LOCATOR}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    RETURN    ${price_cents}

Wait Until Basket Total Price Is Ready
    [Documentation]    Retry until the basket total price is a positive number, avoiding the
    ...    async-render gap where the page briefly shows a zero total right after items are
    ...    added, before reading it as a reference value for later comparisons.
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Basket Total Price Should Be Greater Than Zero

Basket Total Price Should Be Greater Than Zero
    [Documentation]    Verify that the basket total price is currently a positive number of cents.
    ${total}=    Read Basket Total Price In Cents
    Should Be True    ${total} > 0

Close Basket Snackbar If Present
    [Documentation]    Close the basket snackbar when it is currently visible.
    Click If Visible    ${BASKET_SNACKBAR_CLOSE_LOCATOR}
