*** Settings ***
Documentation       Reusable API keywords to register and authenticate disposable Juice Shop
...                 accounts. These accounts are disposable test data, so requests and
...                 responses (including the generated password and bearer token) are logged
...                 normally, with nothing muted.

Library             Collections
Library             RequestsLibrary
Resource            ../variables/environment.resource


*** Variables ***
${API_SESSION_ALIAS}                juice_shop_api
${API_ACCOUNT_PREFIX}               api-account
${API_ACCOUNT_DOMAIN}               teqs-consulting.com
${API_ACCOUNT_PASSWORD}             ApiSecretPassword!
${INVALID_API_ACCOUNT_PASSWORD}     WrongApiSecretPassword!
${API_SECURITY_ANSWER}              api-robot-answer


*** Keywords ***
Generate Api Account Email
    [Documentation]    Generate a UUID-based unique email so accounts never collide across
    ...    parallel runs.
    ${unique_suffix}=    Evaluate    uuid.uuid4().hex    modules=uuid
    RETURN    ${API_ACCOUNT_PREFIX}-${unique_suffix}@${API_ACCOUNT_DOMAIN}

Register Api Account
    [Documentation]    Register the given email as a new disposable account using the fixed API
    ...    test password.
    [Arguments]    ${email}
    ${question}=    Fetch First Security Question
    VAR    &{payload}=
    ...    email=${email}
    ...    password=${API_ACCOUNT_PASSWORD}
    ...    passwordRepeat=${API_ACCOUNT_PASSWORD}
    ...    securityQuestion=${question}
    ...    securityAnswer=${API_SECURITY_ANSWER}
    POST On Session    ${API_SESSION_ALIAS}    /api/Users    json=${payload}    expected_status=201

Authenticate Api Account
    [Documentation]    Authenticate the given credentials and return the HTTP status code, the
    ...    bearer token, and basket id. Token and bid are ${NONE} when authentication is rejected.
    [Arguments]    ${email}    ${password}
    Create Api Session
    VAR    &{payload}=    email=${email}    password=${password}
    ${response}=    POST On Session    ${API_SESSION_ALIAS}    /rest/user/login
    ...    json=${payload}    expected_status=any
    VAR    ${status_code}=    ${response.status_code}
    IF    ${status_code} == 200
        VAR    ${authentication}=    ${response.json()}[authentication]
        VAR    ${token}=    ${authentication}[token]
        VAR    ${bid}=    ${authentication}[bid]
    ELSE
        VAR    ${token}=    ${NONE}
        VAR    ${bid}=    ${NONE}
    END
    RETURN    ${status_code}    ${token}    ${bid}

Authentication Should Succeed
    [Documentation]    Verify that the given credentials authenticate successfully and receive a
    ...    token and basket id.
    [Arguments]    ${email}    ${password}
    ${status_code}    ${token}    ${bid}=    Authenticate Api Account    ${email}    ${password}
    Should Be Equal As Integers    ${status_code}    200
    Should Not Be Equal    ${token}    ${NONE}
    Should Not Be Equal    ${bid}    ${NONE}

Authentication Should Be Rejected
    [Documentation]    Verify that the given credentials are rejected and that no token or
    ...    basket id is issued.
    [Arguments]    ${email}    ${password}
    ${status_code}    ${token}    ${bid}=    Authenticate Api Account    ${email}    ${password}
    Should Be Equal As Integers    ${status_code}    401
    Should Be Equal    ${token}    ${NONE}
    Should Be Equal    ${bid}    ${NONE}

Create Api Address
    [Documentation]    Create a saved address for the given bearer token.
    [Arguments]    ${token}    &{address}
    Create Api Session
    VAR    &{headers}=    Authorization=Bearer ${token}
    POST On Session    ${API_SESSION_ALIAS}    /api/Addresss/    json=${address}
    ...    headers=${headers}    expected_status=201

Create Api Card
    [Documentation]    Create a saved payment card for the given bearer token.
    [Arguments]    ${token}    &{card}
    Create Api Session
    VAR    &{headers}=    Authorization=Bearer ${token}
    POST On Session    ${API_SESSION_ALIAS}    /api/Cards/    json=${card}
    ...    headers=${headers}    expected_status=201

Fetch First Security Question
    [Documentation]    Return the first security question.
    Create Api Session
    ${response}=    GET On Session    ${API_SESSION_ALIAS}    /api/SecurityQuestions
    RETURN    ${response.json()}[data][0]

Create Api Session
    [Documentation]    Create (or refresh) the HTTP session.
    Create Session    ${API_SESSION_ALIAS}    ${BASE_URL}
