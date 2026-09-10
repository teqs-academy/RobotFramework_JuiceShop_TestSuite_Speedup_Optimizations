*** Settings ***
Documentation       Applies API-created authentication state to a browser page, so UI suites can
...                 start signed in without visiting the login form.

Library             Browser
Resource            api_auth.resource
Resource            juice_shop.resource


*** Keywords ***
Sign In Current Page Via Api
    [Documentation]    Register a disposable account through the API, apply its session to the
    ...    already-open current page, and return the account email.
    ${email}=    Generate Api Account Email
    Register Api Account    ${email}
    Apply Api Authentication State To Current Page    ${email}
    RETURN    ${email}

Apply Api Authentication State To Current Page
    [Documentation]    Authenticate the given (registered) email through the API and apply
    ...    its session to the current page, then reload so the app treats it as signed in.
    ...
    ...    The Juice Shop client keeps three pieces of client-side state in sync after a real
    ...    login: localStorage.token, sessionStorage.bid, and a same-named token cookie that
    ...    the whoAmI call the basket page relies on for its owner label needs to resolve the
    ...    session. All three must be set here for a fresh context to look identical to a real
    ...    login.
    [Arguments]    ${email}
    ${status_code}    ${token}    ${bid}=    Authenticate Api Account    ${email}    ${API_ACCOUNT_PASSWORD}
    Should Be Equal As Integers    ${status_code}    200
    ...    msg=API authentication did not succeed for the freshly registered account.
    LocalStorage Set Item    token    ${token}
    SessionStorage Set Item    bid    ${bid}
    Add Cookie    token    ${token}    url=${BASE_URL}
    Reload
    Dismiss Startup Dialogs
    Wait Until Shop Catalog Loads
