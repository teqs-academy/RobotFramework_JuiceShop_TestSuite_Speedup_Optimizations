*** Settings ***
Documentation       Login coverage for OWASP Juice Shop.

Resource            ../resources/login.resource

Suite Setup         Open Shop Homepage
Suite Teardown      Close Shared Browser
Test Setup          Open Shop Page In Shared Browser
Test Teardown       Close Current Shop Page

Test Tags           ui    accounta


*** Test Cases ***
Login With Wrong Password
    [Documentation]    Verify that the generated account rejects an invalid password.
    [Tags]    regression
    ${email}=    Create Generated Account
    Login With Wrong Password Should Fail    ${email}

Login With Wrong Username
    [Documentation]    Verify that the generated account rejects an invalid username.
    [Tags]    regression
    ${email}=    Create Generated Account
    Login With Wrong Username Should Fail    ${email}    ${DEFAULT_ACCOUNT_PASSWORD}

Create Account
    [Documentation]    Create a fresh timestamped account for the login flow.
    [Tags]    smoke
    Create Generated Account

Login With Created Account
    [Documentation]    Log in with a newly created account. Afterwards, log out.
    [Tags]    smoke
    ${email}=    Create Generated Account
    Login With Generated Account    ${email}    ${DEFAULT_ACCOUNT_PASSWORD}
