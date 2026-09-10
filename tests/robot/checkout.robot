*** Settings ***
Documentation       Checkout journey coverage for OWASP Juice Shop.

Resource            ../resources/checkout.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup

Test Tags           ui    checkout    authenticated    regression


*** Test Cases ***
Complete Checkout With A Single Product
    [Documentation]    Verify that a signed-in shopper can check out a single product with
    ...    standard delivery, and that both the order review and the completed order
    ...    confirmation reflect the correct item, subtotal, delivery amount, and final total.
    [Tags]    smoke
    Prepare Checkout Ready Account
    Add Single Product To Basket
    ${product_name}=    Read First Basket Item Name
    ${unit_price}=    Read First Basket Item Price In Cents
    Complete Checkout Selections
    Order Review Item Should Be    ${product_name}    1    ${unit_price}
    Order Review Totals Should Be    ${unit_price}    0    ${unit_price}
    Place Order
    Order Confirmation Item Should Be    ${product_name}    1    ${unit_price}    ${unit_price}
    Order Confirmation Totals Should Be    ${unit_price}    0    ${unit_price}

Complete Checkout With Two Products
    [Documentation]    Verify that checkout correctly identifies each of two distinct,
    ...    named products and sums the subtotal and total across both.
    Prepare Checkout Ready Account
    Add Apple And Banana To Basket
    ${apple_price}    ${banana_price}=    Read Apple And Banana Prices From Basket
    ${expected_total}=    Read Basket Total Price In Cents
    Complete Checkout Selections
    Order Review Should Show Apple And Banana    ${apple_price}    ${banana_price}
    Order Review Totals Should Be    ${expected_total}    0    ${expected_total}
    Place Order
    Order Confirmation Totals Should Be    ${expected_total}    0    ${expected_total}

Complete Checkout With Non Standard Delivery
    [Documentation]    Verify that choosing a non-default delivery speed changes the delivery
    ...    amount and final total accordingly, for both the order review and the completed
    ...    order confirmation.
    Prepare Checkout Ready Account
    Add Single Product To Basket
    ${unit_price}=    Read First Basket Item Price In Cents
    Complete Checkout Selections    1
    ${expected_total}=    Evaluate    int($unit_price) + 50
    Order Review Totals Should Be    ${unit_price}    50    ${expected_total}
    Place Order
    Order Confirmation Totals Should Be    ${unit_price}    50    ${expected_total}

Complete Checkout With A UI Saved Card
    [Documentation]    Verify that a payment card saved through its own UI form is selectable
    ...    and usable at the checkout payment step.
    VAR    &{card}=    fullName=Checkout Tester    cardNum=4111111111111111    expMonth=6
    ...    expYear=2099
    Prepare Checkout Ready Account With UI Saved Card    &{card}
    Add Single Product To Basket
    Complete Checkout Selections
    Place Order
