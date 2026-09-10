*** Settings ***
Documentation       Language switching coverage for OWASP Juice Shop.

Resource            ../resources/language.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup

Test Tags           ui    language


*** Test Cases ***
Switch Language To German
    [Documentation]    Verify that switching to German updates the language button and
    ...    translates a stable UI label, starting from a fresh anonymous context.
    [Tags]    smoke
    Language Button Should Show    EN
    Switch Language To German
    Language Button Should Show    DE
    Basket Label Should Show    Dein Warenkorb

Switch Language Back To English
    [Documentation]    Verify that switching back to English updates the language button and
    ...    translates a stable UI label, starting from a fresh anonymous context.
    [Tags]    regression
    Switch Language To German
    Language Button Should Show    DE
    Switch Language To English
    Language Button Should Show    EN
    Basket Label Should Show    Your Basket
