*** Settings ***
Documentation       Reusable keywords for the Order History page.

Resource            juice_shop.resource


*** Variables ***
${ORDER_HISTORY_LINK_LOCATOR}                   text=Order History
${ORDER_HISTORY_PAGE_LOCATOR}                   css=app-order-history
${ORDER_HISTORY_EMPTY_STATE_TEXT_LOCATOR}       css=.emptyState mat-card-content .noResultText
${ORDER_HISTORY_FIRST_ROW_PRODUCT_LOCATOR}      css=app-order-history mat-row >> nth=0 >> css=.cdk-column-product
${ORDER_HISTORY_FIRST_ROW_QUANTITY_LOCATOR}     css=app-order-history mat-row >> nth=0 >> css=.cdk-column-quantity
${ORDER_HISTORY_FIRST_ROW_TOTAL_LOCATOR}        css=app-order-history mat-row >> nth=0 >> css=.cdk-column-total-price


*** Keywords ***
Open Order History Page
    [Documentation]    Navigate to the Order History page through the account menu.
    Open Orders And Payment Submenu
    Wait For Elements State    ${ORDER_HISTORY_LINK_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${ORDER_HISTORY_LINK_LOCATOR}
    Wait For Elements State    ${ORDER_HISTORY_PAGE_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Order History Should Be Empty
    [Documentation]    Verify that the order history page shows its no-orders empty state.
    Wait For Elements State    ${ORDER_HISTORY_EMPTY_STATE_TEXT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Order History Should Show Order
    [Documentation]    Retry until the first order-history row shows the given product name,
    ...    quantity, and total price, in cents.
    [Arguments]    ${product_name}    ${quantity}    ${total_price_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Order History Should Show Order Exactly    ${product_name}    ${quantity}    ${total_price_cents}

Order History Should Show Order Exactly
    [Documentation]    Verify the first order-history row's product name, quantity, and total
    ...    price, in cents.
    [Arguments]    ${product_name}    ${quantity}    ${total_price_cents}
    ${name}=    Get Text    ${ORDER_HISTORY_FIRST_ROW_PRODUCT_LOCATOR}
    ${quantity_text}=    Get Text    ${ORDER_HISTORY_FIRST_ROW_QUANTITY_LOCATOR}
    ${total_text}=    Get Text    ${ORDER_HISTORY_FIRST_ROW_TOTAL_LOCATOR}
    ${total_cents}=    Parse Price Text To Cents    ${total_text}
    Should Be Equal As Strings    ${name}    ${product_name}    strip_spaces=True
    Should Be Equal As Strings    ${quantity_text}    ${quantity}    strip_spaces=True
    Should Be Equal As Integers    ${total_cents}    ${total_price_cents}
