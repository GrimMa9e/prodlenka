Meta:
    @testCaseId TC-00001
    @feature Shopping Cart
    @priority 2

Scenario: Add item to cart, verify badge and cart contents, then remove item and verify cart is empty
When I login to web app with username `${username}` and password `${password}`

!-- Step 2: Add first item (Sauce Labs Backpack) from inventory page
When I click on element located by `cssSelector([data-test="add-to-cart-sauce-labs-backpack"])`

!-- Step 3: Verify cart badge shows 1
When I wait until element located by `cssSelector([data-test="shopping-cart-badge"])` contains text `1`

!-- Step 4: Open cart
When I click on element located by `cssSelector([data-test="shopping-cart-link"])`
When I wait until element located by `caseInsensitiveText(Your Cart)` appears

!-- Step 5: Verify item is present in cart
Then text `Sauce Labs Backpack` exists

!-- Step 6: Click Remove
When I click on element located by `cssSelector([data-test="remove-sauce-labs-backpack"])`

!-- Step 7: Verify item disappears from cart
When I wait until element located by `caseInsensitiveText(Sauce Labs Backpack)` disappears

!-- Step 8: Verify cart badge is no longer shown
When I wait until element located by `cssSelector([data-test="shopping-cart-badge"])` disappears
