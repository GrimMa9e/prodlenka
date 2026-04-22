Meta:
    @testCaseId TC-00001
    @requirementId REQ-00001
    @feature Inventory Sorting
    @priority 3

Scenario: Verify inventory sorting by Name Z to A remains on inventory page
!-- [ASSUMPTION] Requirement ID was not provided, placeholder REQ-00001 is used and requires validation.
When I login to web app with username `${username}` and password `${password}`
Then `#{extractPathFromUrl(${current-page-url})}` is equal to `/inventory.html`
When I select `Name (Z to A)` in dropdown located by `cssSelector([data-test='product-sort-container'])`
When I change context to element located by `cssSelector(.product_sort_container)`
Then number of elements found by `caseSensitiveText(Name (Z to A))` is equal to `1`
When I change context to element located by `cssSelector([data-test='inventory-list'] > [data-test='inventory-item']:first-child)`
Then number of elements found by `caseSensitiveText(Test.allTheThings() T-Shirt (Red))` is equal to `1`
When I change context to element located by `cssSelector([data-test='inventory-list'] > [data-test='inventory-item']:last-child)`
Then number of elements found by `caseSensitiveText(Sauce Labs Backpack)` is equal to `1`
When I reset context
Then number of elements found by `cssSelector([data-test='inventory-list'])` is equal to `1`
Then `#{extractPathFromUrl(${current-page-url})}` is equal to `/inventory.html`
