Meta:
    @testCaseId TC-AddOnesieToCart-Checkout
    @feature Shopping Cart & Checkout
    @priority 2

Lifecycle:
Before:
Scope: STORY
Examples:
|firstName|lastName|postalCode|
|John     |Doe     |12345     |

Scenario: Add Onesie to cart and complete checkout
When I login to web app with username `${username}` and password `${password}`
When I wait until element located by `caseInsensitiveText(Products)` appears
When I click on element located by `cssSelector([data-test="add-to-cart-sauce-labs-onesie"])`
When I click on element located by `cssSelector(.shopping_cart_link)`
When I wait until element located by `caseInsensitiveText(Your Cart)` appears
Then text `Sauce Labs Onesie` exists
When I click on element located by `cssSelector([data-test="checkout"])`
When I wait until element located by `caseInsensitiveText(Checkout: Your Information)` appears
When I enter `<firstName>` in field located by `cssSelector([data-test="firstName"])`
When I enter `<lastName>` in field located by `cssSelector([data-test="lastName"])`
When I enter `<postalCode>` in field located by `cssSelector([data-test="postalCode"])`
When I click on element located by `cssSelector([data-test="continue"])`
When I wait until element located by `caseInsensitiveText(Checkout: Overview)` appears
Then text `Sauce Labs Onesie` exists
When I click on element located by `cssSelector([data-test="finish"])`
When I wait until element located by `caseInsensitiveText(Checkout: Complete!)` appears
Then text `Thank you for your order!` exists
