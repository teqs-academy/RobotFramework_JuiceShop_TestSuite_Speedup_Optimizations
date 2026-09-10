*** Settings ***
Documentation       Pure API coverage for Juice Shop account registration and authentication.

Resource            ../resources/api_auth.resource

Test Tags           api    authentication


*** Test Cases ***
Registered Account Authenticates Successfully
    [Documentation]    Verify that a freshly registered account authenticates and receives
    ...    a bearer token and a basket id.
    ${email}=    Generate Api Account Email
    Register Api Account    ${email}
    Authentication Should Succeed    ${email}    ${API_ACCOUNT_PASSWORD}

Authentication Is Rejected With Wrong Password
    [Documentation]    Verify that the registered account rejects an incorrect password and
    ...    that no token or basket id is returned.
    ${email}=    Generate Api Account Email
    Register Api Account    ${email}
    Authentication Should Be Rejected    ${email}    ${INVALID_API_ACCOUNT_PASSWORD}
