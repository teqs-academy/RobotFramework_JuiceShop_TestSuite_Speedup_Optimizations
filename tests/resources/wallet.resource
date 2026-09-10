*** Settings ***
Documentation       Reusable keywords for the Digital Wallet: reading its balance and depositing
...                 money into it.

Resource            juice_shop.resource
Resource            payment.resource


*** Variables ***
${DIGITAL_WALLET_LINK_LOCATOR}      text=Digital Wallet
${WALLET_BALANCE_LOCATOR}           css=app-wallet .confirmation
${WALLET_AMOUNT_INPUT_LOCATOR}      css=[aria-label="Enter an amount"]
${WALLET_DEPOSIT_BUTTON_LOCATOR}    css=#submitButton


*** Keywords ***
Open Digital Wallet Page
    [Documentation]    Navigate to the Digital Wallet page through the account menu.
    Open Orders And Payment Submenu
    Wait For Elements State    ${DIGITAL_WALLET_LINK_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${DIGITAL_WALLET_LINK_LOCATOR}
    Wait For Elements State    ${WALLET_AMOUNT_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Read Wallet Balance In Cents
    [Documentation]    Return the current wallet balance, in cents.
    ${balance_text}=    Get Text    ${WALLET_BALANCE_LOCATOR}
    ${balance_cents}=    Parse Price Text To Cents    ${balance_text}
    RETURN    ${balance_cents}

Empty Wallet Amount Submission Should Be Disabled
    [Documentation]    Verify that the Deposit button stays disabled when no amount has been entered.
    ${is_disabled}=    Get Property    ${WALLET_DEPOSIT_BUTTON_LOCATOR}    disabled
    Should Be True    ${is_disabled}

Deposit Amount Into Wallet Using Saved Card
    [Documentation]    Enter the given amount, submit it, select the first saved payment card on
    ...    the resulting payment-selection screen, and continue. The wallet redirects back to
    ...    itself once the deposit completes.
    [Arguments]    ${amount}
    Fill Text    ${WALLET_AMOUNT_INPUT_LOCATOR}    ${amount}
    Click    ${WALLET_DEPOSIT_BUTTON_LOCATOR}
    Wait For Elements State    ${FIRST_SELECTION_ROW_RADIO_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${FIRST_SELECTION_ROW_RADIO_LOCATOR}
    Click    ${PAYMENT_CONTINUE_BUTTON_LOCATOR}
    Wait For Elements State    ${WALLET_AMOUNT_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Wallet Balance Should Be In Cents
    [Documentation]    Retry until the wallet balance matches the expected value, in cents.
    [Arguments]    ${expected_cents}
    Wait Until Keyword Succeeds    ${ASSERTION_RETRY_TIMEOUT}    ${ASSERTION_RETRY_INTERVAL}
    ...    Wallet Balance Should Be Exactly In Cents    ${expected_cents}

Wallet Balance Should Be Exactly In Cents
    [Documentation]    Verify that the wallet balance exactly matches the expected value, in cents.
    [Arguments]    ${expected_cents}
    ${actual_cents}=    Read Wallet Balance In Cents
    Should Be Equal As Integers    ${actual_cents}    ${expected_cents}
