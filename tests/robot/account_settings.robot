*** Settings ***
Documentation       Saved addresses, payment cards, the digital wallet, order history,
...                 and the profile page, validating each UI form/page once through a
...                 freshly authenticated account.

Resource            ../resources/account.resource
Resource            ../resources/payment.resource
Resource            ../resources/authenticated_browser.resource
Resource            ../resources/checkout.resource
Resource            ../resources/wallet.resource
Resource            ../resources/order_history.resource
Resource            ../resources/profile.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup

Test Tags           ui    account    authenticated


*** Test Cases ***
Add And Show Saved Address
    [Documentation]    Verify that a newly added address appears correctly in the saved-addresses list.
    [Tags]    smoke
    Sign In Current Page Via Api
    Open Saved Addresses Page
    VAR    &{address}=
    ...    country=Germany
    ...    fullName=Account Settings Tester
    ...    mobileNum=612345678
    ...    zipCode=13131
    ...    streetAddress=Teststraße 1
    ...    city=Berlin
    ...    state=Ber
    Add New Address    &{address}
    Saved Address Should Show    Account Settings Tester    Teststraße 1, Berlin, Ber, 13131
    ...    Germany

Add And Show Saved Payment Card
    [Documentation]    Verify that a newly added card appears with a masked number in the
    ...    saved payment methods list.
    [Tags]    smoke
    Sign In Current Page Via Api
    Open Saved Payment Methods Page
    VAR    &{card}=
    ...    fullName=Account Settings Tester
    ...    cardNum=4111111111111111
    ...    expMonth=6
    ...    expYear=2099
    Add New Card    &{card}
    Saved Card Should Show    ************1111    Account Settings Tester    6/2099

Account Menu Should Show Signed In Email
    [Documentation]    Verify that the account menu displays the signed-in user's email after
    ...    an API-authenticated session.
    [Tags]    regression
    ${email}=    Sign In Current Page Via Api
    Account Menu Should Show Email    ${email}

Add New Address Should Reject Empty Submission
    [Documentation]    Verify that the "Add New Address" form's submit button stays disabled
    ...    when no required fields have been filled in.
    [Tags]    regression
    Sign In Current Page Via Api
    Open Saved Addresses Page
    Empty Address Form Submission Should Be Disabled

Add New Card Should Reject Empty Submission
    [Documentation]    Verify that the "Add new card" form's submit button stays disabled when
    ...    no required fields have been filled in.
    [Tags]    regression
    Sign In Current Page Via Api
    Open Saved Payment Methods Page
    Empty Card Form Submission Should Be Disabled

Digital Wallet Should Reject Empty Deposit
    [Documentation]    Verify that the Digital Wallet's Deposit button stays disabled when no
    ...    amount has been entered.
    [Tags]    regression
    Sign In Current Page Via Api
    Open Digital Wallet Page
    Empty Wallet Amount Submission Should Be Disabled

Wallet Balance Increases After Deposit Using Saved Card
    [Documentation]    Verify that depositing a valid amount into the Digital Wallet, paid with
    ...    a saved payment card, increases the wallet balance by that amount.
    [Tags]    smoke
    Sign In Current Page Via Api
    ${token}=    LocalStorage Get Item    token
    Create Api Card    ${token}    fullName=Wallet Tester    cardNum=4111111111111111
    ...    expMonth=6    expYear=2099
    Open Digital Wallet Page
    ${before}=    Read Wallet Balance In Cents
    VAR    ${deposit_amount}=    10
    Deposit Amount Into Wallet Using Saved Card    ${deposit_amount}
    ${expected}=    Evaluate    int($before) + int($deposit_amount) * 100
    Wallet Balance Should Be In Cents    ${expected}

Order History Should Be Empty For New Account
    [Documentation]    Verify that a freshly authenticated account's order history starts empty.
    [Tags]    regression
    Sign In Current Page Via Api
    Open Order History Page
    Order History Should Be Empty

Order History Shows Completed Order
    [Documentation]    Verify that completing a checkout adds a matching line to the order history.
    [Tags]    regression    checkout
    Prepare Checkout Ready Account
    Add Single Product To Basket
    ${product_name}=    Read First Basket Item Name
    ${unit_price}=    Read First Basket Item Price In Cents
    Complete Checkout Selections
    Place Order
    Open Order History Page
    Order History Should Show Order    ${product_name}    1    ${unit_price}

Account Profile Page Should Be Reachable And Show Core Fields
    [Documentation]    Verify that the account menu's email entry opens the profile page at its
    ...    own /profile URL, that the Image URL, Email, and Username fields are visible, and
    ...    that the Email field shows the signed-in account's own email.
    [Tags]    smoke
    ${email}=    Sign In Current Page Via Api
    Open Profile Page
    Profile Page Should Be Displayed
    Profile Email Field Should Show    ${email}
