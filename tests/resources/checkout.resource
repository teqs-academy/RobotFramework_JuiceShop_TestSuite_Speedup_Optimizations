*** Settings ***
Documentation       Reusable keywords for the end-to-end checkout journey: address, delivery,
...                 and payment selection, order review, and placing the order.

Resource            basket.resource
Resource            api_auth.resource
Resource            payment.resource


*** Variables ***
&{DEFAULT_CHECKOUT_ADDRESS}                     country=Germany
...                                             fullName=Checkout Tester
...                                             mobileNum=612345678
...                                             zipCode=13131
...                                             streetAddress=Teststraße 1
...                                             city=Berlin
...                                             state=Ber
&{DEFAULT_CHECKOUT_CARD}                        fullName=Checkout Tester
...                                             cardNum=4111111111111111
...                                             expMonth=6
...                                             expYear=2099
${CHECKOUT_BUTTON_LOCATOR}                      css=#checkoutButton
${ADDRESS_CONTINUE_BUTTON_LOCATOR}              css=button[aria-label="Proceed to payment selection"]
${DELIVERY_CONTINUE_BUTTON_LOCATOR}             css=button[aria-label="Proceed to delivery method selection"]
${PLACE_ORDER_BUTTON_LOCATOR}                   css=button[aria-label="Complete your purchase"]
${DELIVERY_SPEED_HEADING_LOCATOR}               text=Choose a delivery speed
${PAYMENT_OPTIONS_HEADING_LOCATOR}              text=My Payment Options
${ORDER_REVIEW_ROW_PREFIX_LOCATOR}              css=#app-purchase-basket mat-row
${ORDER_REVIEW_ITEMS_TOTAL_LOCATOR}             css=tr.mat-row:has-text("Items") td.price
${ORDER_REVIEW_DELIVERY_LOCATOR}                css=tr.mat-row:has-text("Delivery") td.price
${ORDER_REVIEW_FINAL_TOTAL_LOCATOR}             css=tr:has-text("Total Price") td.mat-footer-cell.price
${ORDER_CONFIRMATION_HEADING_LOCATOR}           text=Thank you for your purchase!
${ORDER_CONFIRMATION_ITEM_PRODUCT_LOCATOR}      css=.table-container mat-row >> nth=0 >> css=.cdk-column-product
${ORDER_CONFIRMATION_ITEM_QUANTITY_LOCATOR}     css=.table-container mat-row >> nth=0 >> css=.cdk-column-quantity
${ORDER_CONFIRMATION_ITEM_PRICE_LOCATOR}        css=.table-container mat-row >> nth=0 >> css=.cdk-column-price
${ORDER_CONFIRMATION_ITEM_SUBTOTAL_LOCATOR}     css=.table-container mat-row >> nth=0 >> css=.cdk-column-total-price
${ORDER_CONFIRMATION_ITEMS_TOTAL_LOCATOR}       css=table.price-align tr >> nth=0 >> css=td
${ORDER_CONFIRMATION_DELIVERY_LOCATOR}          css=table.price-align tr >> nth=1 >> css=td
${ORDER_CONFIRMATION_FINAL_TOTAL_LOCATOR}       css=table.price-align tr >> nth=3 >> css=td


*** Keywords ***
Prepare Checkout Ready Account
    [Documentation]    Sign in via the API and pre-create a saved address and payment card.
    ${email}=    Sign In Current Page Via Api
    ${token}=    LocalStorage Get Item    token
    Create Api Address    ${token}    &{DEFAULT_CHECKOUT_ADDRESS}
    Create Api Card    ${token}    &{DEFAULT_CHECKOUT_CARD}
    RETURN    ${email}

Prepare Checkout Ready Account With UI Saved Card
    [Documentation]    Sign in via the API, pre-create a saved address via the API, and save a
    ...    payment card through its own UI form.
    [Arguments]    &{card}
    ${email}=    Sign In Current Page Via Api
    ${token}=    LocalStorage Get Item    token
    Create Api Address    ${token}    &{DEFAULT_CHECKOUT_ADDRESS}
    Open Saved Payment Methods Page
    Add New Card    &{card}
    RETURN    ${email}

Add Single Product To Basket
    [Documentation]    Search for the configured search term, add the first visible product to
    ...    the basket, and open the basket page once its total price has settled.
    Search For Product    ${SEARCH_TERM}
    Add First Visible Product To Basket
    Close Basket Snackbar If Present
    Open Basket
    Wait Until Basket Total Price Is Ready

Add Apple And Banana To Basket
    [Documentation]    Add two named, distinct products (Apple Juice, Banana Juice) to the
    ...    basket by name and open it.
    Search For Product    apple
    Add Named Product To Basket    Apple Juice (1000ml)
    Close Basket Snackbar If Present
    Search For Product    banana
    Add Named Product To Basket    Banana Juice (1000ml)
    Close Basket Snackbar If Present
    Open Basket
    Wait Until Basket Total Price Is Ready

Start Checkout From Basket
    [Documentation]    Click the basket page's checkout button and wait for address selection.
    Click    ${CHECKOUT_BUTTON_LOCATOR}
    Wait For Elements State    ${FIRST_SELECTION_ROW_RADIO_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Select First Saved Address And Continue
    [Documentation]    Select the first saved address and proceed to delivery selection.
    Click    ${FIRST_SELECTION_ROW_RADIO_LOCATOR}
    Click    ${ADDRESS_CONTINUE_BUTTON_LOCATOR}
    Wait For Elements State    ${DELIVERY_SPEED_HEADING_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Select Delivery Speed And Continue
    [Documentation]    Select the delivery speed at the given row (0=One Day, 1=Fast,
    ...    2=Standard/free) and proceed to payment selection.
    [Arguments]    ${row_index}=2
    ${radio_locator}=    Selection Row Radio Locator    ${row_index}
    Click    ${radio_locator}
    Click    ${DELIVERY_CONTINUE_BUTTON_LOCATOR}
    Wait For Elements State    ${PAYMENT_OPTIONS_HEADING_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Select First Saved Card And Continue
    [Documentation]    Select the first saved payment card and proceed to order review.
    Click    ${FIRST_SELECTION_ROW_RADIO_LOCATOR}
    Click    ${PAYMENT_CONTINUE_BUTTON_LOCATOR}
    Wait For Elements State    ${ORDER_REVIEW_FINAL_TOTAL_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Complete Checkout Selections
    [Documentation]    Start checkout from the basket and select the first saved address, the
    ...    given delivery speed, and the first saved card, arriving at order review.
    [Arguments]    ${delivery_row_index}=2
    Start Checkout From Basket
    Select First Saved Address And Continue
    Select Delivery Speed And Continue    ${delivery_row_index}
    Select First Saved Card And Continue

Order Review Item Should Be
    [Documentation]    Retry until the order-review page's first basket line shows the given
    ...    product name, quantity, and unit price in cents.
    [Arguments]    ${product_name}    ${quantity}    ${unit_price_cents}
    Order Review Item At Row Should Be    0    ${product_name}    ${quantity}    ${unit_price_cents}

Order Review Item At Row Should Be
    [Documentation]    Retry until the order-review page's basket line at the given row index
    ...    shows the given product name, quantity, and unit price in cents. A retry is needed,
    ...    because these totals resolve asynchronously after the page loads.
    [Arguments]    ${row_index}    ${product_name}    ${quantity}    ${unit_price_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Order Review Item At Row Should Be Exactly
    ...    ${row_index}    ${product_name}    ${quantity}    ${unit_price_cents}

Read Apple And Banana Prices From Basket
    [Documentation]    Return the unit prices, in cents, of the apple and banana basket rows
    ...    added by "Add Apple And Banana To Basket" (apple at row 0, banana at row 1).
    ${apple_price}=    Read Basket Item Price At Row In Cents    0
    ${banana_price}=    Read Basket Item Price At Row In Cents    1
    RETURN    ${apple_price}    ${banana_price}

Order Review Should Show Apple And Banana
    [Documentation]    Verify both order-review basket lines: apple at row 0, banana at row 1.
    [Arguments]    ${apple_price_cents}    ${banana_price_cents}
    Order Review Item At Row Should Be    0    Apple Juice (1000ml)    1    ${apple_price_cents}
    Order Review Item At Row Should Be    1    Banana Juice (1000ml)    1    ${banana_price_cents}

Order Review Row Column Locator
    [Documentation]    Build the locator for the given order-review basket row and column class.
    [Arguments]    ${row_index}    ${column_class}
    ${locator}=    Row Locator At Index    ${ORDER_REVIEW_ROW_PREFIX_LOCATOR}    ${row_index}
    ...    .cdk-column-${column_class}
    RETURN    ${locator}

Order Review Item At Row Should Be Exactly
    [Documentation]    Verify the order-review page's basket line at the given row index:
    ...    product name, quantity, and unit price in cents.
    [Arguments]    ${row_index}    ${product_name}    ${quantity}    ${unit_price_cents}
    ${product_locator}=    Order Review Row Column Locator    ${row_index}    product
    ${quantity_locator}=    Order Review Row Column Locator    ${row_index}    quantity
    ${price_locator}=    Order Review Row Column Locator    ${row_index}    price
    ${name}=    Get Text    ${product_locator}
    ${quantity_text}=    Get Text    ${quantity_locator}
    ${price_text}=    Get Text    ${price_locator}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    Should Be Equal As Strings    ${name}    ${product_name}    strip_spaces=True
    Should Be Equal As Strings    ${quantity_text}    ${quantity}    strip_spaces=True
    Should Be Equal As Integers    ${price_cents}    ${unit_price_cents}

Order Review Items Subtotal Should Be In Cents
    [Documentation]    Retry until the order-review "Items" subtotal matches, in cents.
    [Arguments]    ${expected_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Order Review Items Subtotal Should Be Exactly In Cents    ${expected_cents}

Order Review Items Subtotal Should Be Exactly In Cents
    [Documentation]    Verify the order-review "Items" subtotal in cents.
    [Arguments]    ${expected_cents}
    ${price_text}=    Get Text    ${ORDER_REVIEW_ITEMS_TOTAL_LOCATOR}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    Should Be Equal As Integers    ${price_cents}    ${expected_cents}

Order Review Delivery Amount Should Be In Cents
    [Documentation]    Retry until the order-review "Delivery" amount matches, in cents.
    [Arguments]    ${expected_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Order Review Delivery Amount Should Be Exactly In Cents    ${expected_cents}

Order Review Delivery Amount Should Be Exactly In Cents
    [Documentation]    Verify the order-review "Delivery" amount in cents.
    [Arguments]    ${expected_cents}
    ${price_text}=    Get Text    ${ORDER_REVIEW_DELIVERY_LOCATOR}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    Should Be Equal As Integers    ${price_cents}    ${expected_cents}

Order Review Total Should Be In Cents
    [Documentation]    Retry until the order-review final total matches, in cents.
    [Arguments]    ${expected_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Order Review Total Should Be Exactly In Cents    ${expected_cents}

Order Review Total Should Be Exactly In Cents
    [Documentation]    Verify the order-review final total in cents.
    [Arguments]    ${expected_cents}
    ${price_text}=    Get Text    ${ORDER_REVIEW_FINAL_TOTAL_LOCATOR}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    Should Be Equal As Integers    ${price_cents}    ${expected_cents}

Order Review Totals Should Be
    [Documentation]    Verify the order-review Items subtotal, Delivery amount, and final
    ...    Total, all in cents.
    [Arguments]    ${items_cents}    ${delivery_cents}    ${total_cents}
    Order Review Items Subtotal Should Be In Cents    ${items_cents}
    Order Review Delivery Amount Should Be In Cents    ${delivery_cents}
    Order Review Total Should Be In Cents    ${total_cents}

Place Order
    [Documentation]    Complete the purchase from the order-review page and wait for the
    ...    confirmation page to load.
    Click    ${PLACE_ORDER_BUTTON_LOCATOR}
    Wait For Elements State    ${ORDER_CONFIRMATION_HEADING_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Order Confirmation Item Should Be
    [Documentation]    Retry until the order-confirmation page's single line item shows the
    ...    given product name, quantity, unit price, and line subtotal, all in cents where
    ...    applicable. This proves the completed order has the correct data.
    [Arguments]    ${product_name}    ${quantity}    ${unit_price_cents}    ${subtotal_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Order Confirmation Item Should Be Exactly
    ...    ${product_name}    ${quantity}    ${unit_price_cents}    ${subtotal_cents}

Order Confirmation Item Should Be Exactly
    [Documentation]    Verify the order-confirmation page's single line item: product name,
    ...    quantity, unit price, and line subtotal, all in cents where applicable.
    [Arguments]    ${product_name}    ${quantity}    ${unit_price_cents}    ${subtotal_cents}
    ${name}=    Get Text    ${ORDER_CONFIRMATION_ITEM_PRODUCT_LOCATOR}
    ${quantity_text}=    Get Text    ${ORDER_CONFIRMATION_ITEM_QUANTITY_LOCATOR}
    ${unit_price_text}=    Get Text    ${ORDER_CONFIRMATION_ITEM_PRICE_LOCATOR}
    ${unit_price_actual}=    Parse Price Text To Cents    ${unit_price_text}
    ${subtotal_text}=    Get Text    ${ORDER_CONFIRMATION_ITEM_SUBTOTAL_LOCATOR}
    ${subtotal_actual}=    Parse Price Text To Cents    ${subtotal_text}
    Should Be Equal As Strings    ${name}    ${product_name}    strip_spaces=True
    Should Be Equal As Strings    ${quantity_text}    ${quantity}    strip_spaces=True
    Should Be Equal As Integers    ${unit_price_actual}    ${unit_price_cents}
    Should Be Equal As Integers    ${subtotal_actual}    ${subtotal_cents}

Order Confirmation Totals Should Be
    [Documentation]    Retry until the order-confirmation Items subtotal, Delivery amount, and
    ...    final Total match, all in cents.
    [Arguments]    ${items_cents}    ${delivery_cents}    ${total_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Order Confirmation Totals Should Be Exactly
    ...    ${items_cents}    ${delivery_cents}    ${total_cents}

Order Confirmation Totals Should Be Exactly
    [Documentation]    Verify the order-confirmation Items subtotal, Delivery amount, and
    ...    final Total, all in cents.
    [Arguments]    ${items_cents}    ${delivery_cents}    ${total_cents}
    ${items_text}=    Get Text    ${ORDER_CONFIRMATION_ITEMS_TOTAL_LOCATOR}
    ${items_actual}=    Parse Price Text To Cents    ${items_text}
    ${delivery_text}=    Get Text    ${ORDER_CONFIRMATION_DELIVERY_LOCATOR}
    ${delivery_actual}=    Parse Price Text To Cents    ${delivery_text}
    ${total_text}=    Get Text    ${ORDER_CONFIRMATION_FINAL_TOTAL_LOCATOR}
    ${total_actual}=    Parse Price Text To Cents    ${total_text}
    Should Be Equal As Integers    ${items_actual}    ${items_cents}
    Should Be Equal As Integers    ${delivery_actual}    ${delivery_cents}
    Should Be Equal As Integers    ${total_actual}    ${total_cents}
