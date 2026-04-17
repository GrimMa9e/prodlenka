Meta:
    @feature Product Details
    @priority 3

Scenario: Log in and capture first product details from inventory page
When I login to web app with username `${username}` and password `${password}`
When I save text of element located by `xpath((//div[@data-test='inventory-item-name'])[1])` to story variable `productName`
When I save text of element located by `xpath((//div[@data-test='inventory-item-price'])[1])` to story variable `productPrice`

Scenario: Verify product details page matches inventory page
When I click on element located by `xpath((//a[contains(@data-test, 'title-link')])[1])`
When I wait until element located by `cssSelector([data-test='inventory-item-name'])` appears
When I save text of element located by `cssSelector([data-test='inventory-item-name'])` to scenario variable `detailsProductName`
When I save text of element located by `cssSelector([data-test='inventory-item-price'])` to scenario variable `detailsProductPrice`
Then `${productName}` is equal to `${detailsProductName}`
Then `${productPrice}` is equal to `${detailsProductPrice}`
Then number of elements found by `cssSelector([data-test='inventory-item-desc'])` is equal to `1`

Scenario: Return to inventory page from product details
When I click on element located by `cssSelector([data-test='back-to-products'])`
When I wait until element located by `caseInsensitiveText(Products)` appears
Then `${current-page-url}` matches `.*/inventory\.html.*`
