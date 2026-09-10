*** Settings ***
Documentation       UI-only Robot Framework demo coverage for OWASP Juice Shop.

Resource            ../resources/juice_shop.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup

Test Tags           ui    journeys


*** Test Cases ***
Homepage Smoke
    [Documentation]    Verify that the webshop homepage loads and shows the catalog.
    [Tags]    smoke
    Catalog Should Show Products

Product Discovery
    [Documentation]    Verify that a shopper can search and still see matching catalog results.
    [Tags]    regression
    Search For Product    ${SEARCH_TERM}
    Catalog Should Show Products

Product Details
    [Documentation]    Verify that a shopper can open the product details dialog.
    [Tags]    regression
    Search For Product    ${SEARCH_TERM}
    Open First Product Details
    Details Dialog Should Be Visible
    Close Product Details

Homepage Banner Returns To Catalog
    [Documentation]    Verify that clicking the navbar banner navigates from the basket page
    ...    back to the homepage catalog.
    [Tags]    smoke
    Open Basket
    ${basket_url}=    Get Url
    Should Contain    ${basket_url}    /basket
    Go To Homepage Via Banner
    ${home_url}=    Get Url
    Should Contain    ${home_url}    /search
