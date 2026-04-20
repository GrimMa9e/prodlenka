Meta:
    @feature Checkout
    @priority 2

Scenario: Checkout validation error is shown when First Name is missing
When I login to web app with username `${username}` and password `${password}`
When I click on element located by `id(add-to-cart-sauce-labs-backpack)`
When I click on element located by `cssSelector([data-test="shopping-cart-link"])`
When I wait until element located by `caseInsensitiveText(Your Cart)` appears
When I click on element located by `id(checkout)`
When I wait until element located by `caseInsensitiveText(Checkout: Your Information)` appears
When I enter `Smith` in field located by `id(last-name)`
When I enter `12345` in field located by `id(postal-code)`
When I click on element located by `id(continue)`
Then text `Error: First Name is required` exists
!-- [ASSUMPTION] TC Step 10: Verifying the error text above implicitly confirms the user remains on
!-- checkout-step-one.html, as "Error: First Name is required" only appears on that page.
!-- No separate page-presence check is added to avoid redundant verification of the already-waited heading.
