# Test Case TC-00001 - Summary

## Test Information
- **Test Case ID**: TC-00001
- **Title**: Add item to cart, verify badge, remove item, verify cart empty
- **Execution Date**: 2026-04-17
- **Status**: PASSED

## Coverage Report

| # | Test Case Step | Expected Result | Actual Result | Status | Notes |
|---|----------------|-----------------|---------------|--------|-------|
| 1 | Log in | User is on inventory page | Redirected to `/inventory.html`; `react-burger-menu-btn` visible | ✅ | Composite step `When I login to web app with username ... and password ...` used |
| 2 | Add one item from inventory page | Item is added; button changes to "Remove" | `[data-test="add-to-cart-sauce-labs-backpack"]` clicked; button changed to `Remove` (`[data-test="remove-sauce-labs-backpack"]`) | ✅ | Sauce Labs Backpack selected as the test item (first item in list) 🔵 Assumed |
| 3 | Verify cart badge shows 1 | Cart badge shows `1` | `[data-test="shopping-cart-badge"]` appeared with text `1` | ✅ | `When I wait until element located by cssSelector([data-test="shopping-cart-badge"]) contains text \`1\`` |
| 4 | Open cart | Cart page opens | Navigated to `/cart.html`; "Your Cart" heading visible | ✅ | Click `[data-test="shopping-cart-link"]` + wait for "Your Cart" text |
| 5 | Verify item is present | Item name visible in cart | `Sauce Labs Backpack` text present on page | ✅ | `Then text \`Sauce Labs Backpack\` exists` |
| 6 | Click Remove | Remove button is clicked | `[data-test="remove-sauce-labs-backpack"]` clicked successfully | ✅ | Item-specific `data-test` remove button used |
| 7 | Verify item disappears from cart | Sauce Labs Backpack no longer visible | Item text disappeared from DOM after click | ✅ | `When I wait until element located by caseInsensitiveText(Sauce Labs Backpack) disappears` |
| 8 | Verify cart badge is no longer shown | Cart badge disappears | `[data-test="shopping-cart-badge"]` no longer present in DOM | ✅ | `When I wait until element located by cssSelector([data-test="shopping-cart-badge"]) disappears` |

**Status Legend**: ✅ Covered | ⚠️ Gap | ❌ Discrepancy | 🔵 Assumed

### Coverage Summary
- **Total Steps**: 8
- **Fully Covered**: 8 (✅)
- **Gaps (Missing Steps)**: 0 (⚠️)
- **Discrepancies**: 0 (❌)
- **Assumed**: 1 (🔵)
- **Coverage Percentage**: 100%

## Discrepancies Found

None.

## Missing VIVIDUS Steps

None. All test case actions are fully supported by available VIVIDUS steps.

## Assumptions Made

**IMPORTANT: Review all assumptions below and validate they match intended behavior.**

| Step # | Original TC Instruction | Assumption Made | Rationale | Needs Validation |
|--------|------------------------|-----------------|-----------|------------------|
| 2 | "Add one item from inventory page" | Used **Sauce Labs Backpack** (first item in the default A-to-Z sorted list) | No specific item was mentioned; first item selected for simplicity | ⚠️ YES — confirm which item should be used, or if any item is acceptable |
