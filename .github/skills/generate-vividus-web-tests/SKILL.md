---
name: generate-vividus-web-tests
description: 'Generate VIVIDUS test automation stories from test cases for web applications. Creates executable .story files following VIVIDUS syntax and project conventions. Use when: automating web test cases, converting manual tests to VIVIDUS stories, generating web UI test automation.'
argument-hint: 'Enter your test case...'
---

## Process Overview

1. **Retrieve** test cases to automate
2. **Execute** test cases with Playwright
3. **Analyze** test case coverage
4. **Explore** VIVIDUS story writing guidelines
5. **Generate** VIVIDUS stories & Summary report

---

## Step 1: Retrieve test cases

Extract test case(s) from the user's prompt input.

Each test case **must** contain:
- **Test Steps**: Numbered, sequential actions to perform
- **Expected Results**: Clear, verifiable outcomes for each step or the entire test

**ABORT** further execution if:
- Test steps are missing or not provided
- Expected results are not defined
- Input does not represent a valid test case structure

When aborting, explain what is missing and request a complete test case.

---

## Step 2: Execute test cases

Use Playwright MCP to execute test cases and collect element locators for VIVIDUS story generation in Step 4.

### Execution process

1. **Navigate**: `browser_navigate(url)` - URL from test case or user prompt

2. **For each test step**:
   - **DO NOT take screenshots**, use `browser_snapshot()` to take a page snapshot to understand page structure and its elements
   - Identify key elements from test cases e.g. form fields, interactive elements, visual components etc. and document their refs, text content and labels, states
   - Collect stable locator attributes: IDs, data-testid, aria-labels, exact button/link text
   - Perform actions to verify element behaviors: `browser_click`, `browser_type`, `browser_select_option`, or `browser_run_code`
   - Document any differences from expected results or any missing or changed elements

3. **Dynamic content**: `browser_wait_for(text)` for async operations

### Assumption Handling

When encountering unclear steps in test cases, or when blocked the agent should:
1. Proceed with reasonable assumption or workaround
2. Document assumption or workaround clearly
3. Flag for user validation in summary report

Example assumptions:
| Situation | Assumption Made |Marked As |
|-----------|-----------------|-----------|
| Button text unclear in TC | Used actual text from app exploration | 🔵 Assumed |
| Sort order not specified | Assumed descending by date (most recent first) | 🔵 Assumed |
| Element locator not unique | Used more specific parent context | 🔵 Assumed |
| Expected state not defined | Assumed element should be visible and enabled | 🔵 Assumed |

### When to STOP and Ask (Do NOT Assume)

Do **NOT** proceed with assumptions in these situations. Stop execution and request clarification:

| Situation | Why Ask |
|-----------|---------|
| Authentication credentials required but not provided | Security-sensitive, cannot guess |
| Target environment URL missing or unclear | Wrong environment could cause data issues |
| Test references external dependencies (APIs, databases) not accessible | Cannot verify integration behavior |
| Expected result describes business logic that cannot be verified visually | Requires domain knowledge |
| Test case references another TC ("See TC-XXX") that is not provided | Missing context for complete execution |
| Multiple valid interpretations exist with significantly different outcomes | Assumption could invalidate entire test |

---

## Step 3: Analyze Coverage & Map to VIVIDUS

### Logic & Flow Planning
**Before choosing any steps**, write out the logical flow of the test to ensure it makes functional sense.
1. Identify the *high-level* actions (e.g., "Login", "Navigate to User Profile", "Change Password").
2. Ensure the sequence handles state changes (e.g., "Page must be reloaded after saving" or "Modal must be closed").
3. Check for specific negative scenarios: Ensure the test verifies the *fail state* (e.g., "Error message visible") and doesn't accidentally succeed if the error is missing.

### Discovery & Marking
VIVIDUS capabilities and project discovery:
1. **MUST** fetch available VIVIDUS steps by calling the MCP tool matching pattern `vividus_get_all_features`
   - **ABORT** if the VIVIDUS MCP tool is not available or not connected. Instruct the user to connect the VIVIDUS MCP server before proceeding. Without this tool, valid steps cannot be discovered and stories will contain incorrect syntax.
2. Read existing resources to learn patterns and conventions:
    - `src/main/resources/story/**/*.story` — existing stories
    - `src/main/resources/steps/*.steps` — reusable composite steps
3. Lifecycle and Examples usage (transformers, data tables), scenario structure and naming, meta tags

⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

**Strict** rules to adhere:
1. **ONLY use steps returned by the MCP tool matching pattern `vividus_get_all_features`** — NEVER invent, modify, or assume steps that are not explicitly listed
2. **Preserve exact syntax** - do not modify step parameters or structure
3. **Use exact locator strategies**: `cssSelector`, `xpath`, `id`, `caseInsensitiveText`, `name`
4. **If a required step is NOT available** - DO NOT silently ignore, mark as `[MISSING STEP]`

### Coverage Mapping

In summary report for each test case step, assess coverage status and notes:

| TC Step | Action | Status | Notes |
|---------|--------|--------|-------|
| 1 | Log in as Global Admin | ✅ Covered | Requires navigation + cookie/auth handling |
| 2 | Navigate to Companies page | ✅ Covered | Click + wait for page load |
| 3 | Verify tooltip on hover | ⚠️ Gap | No tooltip verification step in VIVIDUS |
| 4 | Drag item to new position | ✅ Covered | Single drag-and-drop step available |
| 5 | Verify sorting order | 🔵 Assumed | Unclear if alphabetical or by date |
| 6 | Check error message style | ❌ Discrepancy | Expected red text, actual is orange |

### Coverage Status Legend
- ✅ **Covered** - Can be implemented with available VIVIDUS steps
- ⚠️ **Gap** - No VIVIDUS step available, manual intervention needed
- ❌ **Discrepancy** - Expected behavior differs from actual
- 🔵 **Assumed** - Input was unclear or incomplete; a best-guess decision was made (requires validation)

## Step 4: VIVIDUS Story Guidelines

### General rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **Locators:** Follow the **Strict Hierarchy** below to ensure stability.
3. **Data Tables:** Use Examples blocks for parameterized scenarios
4. **Composite Steps:** Reuse existing composite steps; propose new ones for repeated patterns
5. **Contextual Steps:** When using parent element context, ensure child locators are relative
6. **No Hardcoded Values:** Do NOT hardcode sensitive or environment-specific values (credentials, URLs, API keys, etc.) directly in story steps. Use variables from properties files instead. If properties are not available, use placeholder variables and document them.

### Locator Stability Hierarchy
When identifying elements, you **MUST** prefer locators in this order:

1.  🥇 **Exquisite**: `data-testid`, `data-test`, `data-qa`
2.  🥈 **High**: `id` (ONLY if it looks human-readable and stable, e.g., `#submit-btn`. REJECT auto-generated IDs like `#ember123`)
3.  🥉 **Medium**: `buttonName()` or `linkText()` (Semantic and readable)
4.  ⚠️ **Low**: `caseInsensitiveText()` or `formName/fieldName` (Use with caution for localization)
5.  ⛔ **Last Resort**: `cssSelector` or `xpath` (Only if NO other option exists. XPath must be robust, avoiding indexing like `div[3]/span[2]`)

### Selecting a Specific Element (e.g., the First One)

**Avoid selecting elements by index** unless absolutely necessary and there is no other way to select the element. First, try to find a more specific locator that uniquely identifies the element. Only if that is not possible, use index-based selection with the appropriate approach depending on the locator type:

- **For XPath locators**: Use native XPath indexing to select a specific element by position.
- **For other locator types** (`cssSelector`, `buttonName`, `caseInsensitiveText`, etc.): Use the `->filter.index(N)` expression appended to the locator.
- **Avoid combining XPath with `->filter.index()`**

**Index is 1-based** — position `1` or `->filter.index(1)` selects the first element, `2` / `->filter.index(2)` selects the second, etc.

✅ **Good** - XPath with native positional indexing:
```gherkin
When I save text of element located by `xpath((//div[@data-test='inventory-item-name'])[1])` to story variable `productName`
When I save text of element located by `xpath((//div[@data-test='inventory-item-price'])[1])` to story variable `productPrice`
When I click on element located by `xpath((//a[contains(@data-test, 'title-link')])[1])`
```

✅ **Good** - non-XPath locators with `->filter.index()`:
```gherkin
When I click on element located by `cssSelector(.inventory_item)->filter.index(1)`
When I click on element located by `buttonName(Add to cart)->filter.index(2)`
```

❌ **Bad** - combining XPath with `->filter.index()` (inefficient):
```gherkin
When I save text of element located by `xpath(//div[@data-test='inventory-item-name'])->filter.index(1)` to story variable `productName`
When I click on element located by `xpath(//a[contains(@data-test, 'title-link')])->filter.index(1)`
```

### Avoid Redundant Verifications

Do NOT verify the same element/text twice. If you wait for an element, it's already verified.

❌ **Bad** - redundant check:
```gherkin
When I wait until element located by `caseInsensitiveText(My Account)` appears
Then text `My Account` exists
```

✅ **Good** - single verification:
```gherkin
When I wait until element located by `caseInsensitiveText(My Account)` appears
```

### Prefer buttonName Locator for Buttons

When interacting with button HTML elements, use `buttonName` locator instead of xpath.

❌ **Bad** - verbose xpath:
```gherkin
When I click on element located by `xpath(//button[contains(text(),'Save')])`
```

✅ **Good** - clean buttonName locator:
```gherkin
When I click on element located by `buttonName(Save)`
```

### Synchronize After Navigation

**CRITICAL RULE**: When navigating to a new page or opening a new tab, **ALWAYS** add a wait step for FIRST **interactive element** on that page or tab. This ensures the page has fully loaded and all subsequent interactive elements are available.

**Why**: Waiting for the first interactive element on a page guarantees that:
- The page DOM is fully rendered
- JavaScript has executed and initialized components
- All form fields, buttons, and other interactive elements are ready
- Subsequent steps won't fail due to elements not being available yet

✅ **Good** - wait for first interactive element after navigation:
```gherkin
When I click on element located by `buttonName(Add Product)`
When I wait until element located by `caseInsensitiveText(Create Product)` appears

!-- Now safe to interact with form fields without additional waits
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
When I enter `${campaignName}` in field located by `xpath(//input[@placeholder='URL'])`
```

❌ **Bad** - no synchronization after navigation:
```gherkin
When I click on element located by `buttonName(Add Product)`
!-- Missing wait - next step may fail if page hasn't loaded
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
```

❌ **Bad** - waiting before every field (unnecessary):
```gherkin
When I click on element located by `buttonName(Create Product)`
When I wait until element located by `xpath(//input[@name='name'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
When I wait until element located by `xpath(//input[@placeholder='URL'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@placeholder='URL'])`
```

**When to wait:**
- ✅ After clicking navigation links (new page loads)
- ✅ After clicking buttons that open new tabs or modals
- ✅ After dropdown selections that dynamically load/show new fields
- ✅ After form submissions that redirect to different pages
- ❌ Before every field on the same page (only first element needed)
- ❌ Between consecutive actions on already-loaded elements

### Verify Page URL After Navigation

When a test case requires verifying that a navigation action landed on the correct page, **prefer URL validation** using the `${current-page-url}` dynamic variable.

**Priority order for page verification:**
1. **URL validation using `${current-page-url}`** — preferred, deterministic, does not depend on UI rendering
2. **Unique element verification** — only if URL validation is not possible or insufficient (e.g., single-page apps where URL doesn't change)

✅ **Good** - verify URL contains expected path segment:
```gherkin
When I click on element located by `caseInsensitiveText(Back to Products)`
Then `${current-page-url}` matches `.*/inventory\.html.*`
```

❌ **Bad** - verifying page only by element when URL check would suffice:
```gherkin
When I click on element located by `caseInsensitiveText(Back to Products)`
!-- URL check would be more reliable here
Then text `Products` exists
```

## Step 5: Generate VIVIDUS story & Summary report

### Output Folder Structure
Create a new folder for each test case in project root for user review:

```
src/main/resources/story/web_app/
├── [TestName].story          # VIVIDUS story file
├── test-data/                # Generated test data (images, files, etc.)
│   └── [any required files]
└── summary.md                # Coverage report and findings
```

User will review and move story files to appropriate place after approval.

**DO NOT create:**
- Quick start guides
- README files
- Additional documentation
- Any other markdown files beyond mentioned ones

### Output Files

#### File 1: VIVIDUS Story
**Location**: `src/main/resources/story/web_app/[TestName].story`

```gherkin
Meta:
    @testCaseId [Test Case ID]
    @requirementId [Requirement Id]
    @feature [Feature]
    @priority [0|1|2|3|4]

Scenario: [Descriptive scenario name]
[Steps using ONLY available VIVIDUS syntax]

!-- [MISSING STEP] Comment for any gaps
!-- [ASSUMPTION] Comment for any assumptions made - REQUIRES VALIDATION
```

**Meta Tag Guidelines:**

Use the `Meta:` block **only at the story level** (before the first scenario), not within individual scenarios.

| Tag | Values | Description |
|-----|--------|-------------|
| `@testCaseId` | `TC-XXXXX` | Exact TestRail/Jira ID (e.g., `TC-12345`) |
| `@requirementId` | `REQ-XXXXX` | Linked requirement/user story ID |
| `@feature` | Feature name | Should match feature folder or test suite |
| `@priority` | `1` \| `2` \| `3` \| `4` \| `5` | 1=Blocker, 2=Critical, 3=Major, 4=Minor, 5=Trivial |

**Assumption Comments in Story:**
```gherkin
!-- [ASSUMPTION] TC step said "click submit" but button text is "Save" - using "Save"
When I click on element located by `xpath(//button[text()='Save'])`

!-- [ASSUMPTION] TC doesn't specify wait time, assuming 10 seconds max
When I wait until element located by `caseInsensitiveText(Success)` appears in `PT10S`
```

**Scenario Mapping:**
- Split test cases into **separate scenarios by logical action** (e.g., login, verify inventory page, verify product details, return to inventory)
- Use Examples tables to consolidate similar test cases with different data
- **No duplicate scenarios** — each scenario must be unique and included only once per story. Do not repeat the same logical flow in multiple scenarios

#### File 2: Summary Report
**Location**: `src/main/resources/story/web_app/[TestName] summary.md`

Summary report structure

```markdown
# Test Case [ID] - Summary

## Test Information
- **Test Case ID**: [Test case Id]
- **Title**: [Test case title]
- **Execution Date**: [Date]
- **Status**: [PASSED | PASSED WITH GAPS | FAILED]

## Coverage Report

| # | Test Case Step | Expected Result | Actual Result | Status | Notes |
|---|----------------|-----------------|---------------|--------|-------|
| 1 | [Step description] | [Expected] | [Actual observed] | ✅/⚠️/❌/🔵 | [Implementation notes or gaps] |
| 2 | ... | ... | ... | ... | ... |

**Status Legend**: ✅ Covered | ⚠️ Gap | ❌ Discrepancy | 🔵 Assumed

### Coverage Summary
- **Total Steps**: X
- **Fully Covered**: X (✅)
- **Gaps (Missing Steps)**: X (⚠️)
- **Discrepancies**: X (❌)
- **Assumed**: X (🔵)
- **Coverage Percentage**: X%

## Discrepancies Found

### [Issue Title]
- **Step #**: X
- **Expected**: [What test case says]
- **Actual**: [What was observed]
- **Impact**: [High | Medium | Low]
- **Recommendation**: [Action needed]

## Missing VIVIDUS Steps

List any actions that cannot be automated with available steps:

| Action Needed | Workaround | Priority |
|---------------|------------|----------|
| [Action] | [Possible workaround or "None"] | [High/Medium/Low] |

## Assumptions Made

**IMPORTANT: Review all assumptions below and validate they match intended behavior.**

| Step # | Original TC Instruction | Assumption Made | Rationale | Needs Validation |
|--------|------------------------|-----------------|-----------|------------------|
| X | [What TC said] | [What was assumed] | [Why this assumption] | ⚠️ YES |
```

#### File 3: Test Data (if needed)
**Location**: `src/main/resources/story/web_app/test-data/`
- Upload images, JSON files, or any test data generated during exploration
- Reference in story using relative path: `test-data/[filename]`

---

## Quality Checklist

### Step Compliance
- [ ] All steps exist in VIVIDUS definitions or composite steps
- [ ] Exact VIVIDUS syntax preserved (no modifications)
- [ ] Valid locator strategies: `xpath`, `cssSelector`, `caseInsensitiveText`, `id`, `name`
- [ ] Missing steps marked with `[MISSING STEP]` and ⚠️ warning

### Locator Quality
- [ ] Element text extracted exactly as displayed (preserve case)
- [ ] Locators are specific (no ambiguous matches)
- [ ] Dynamic content handled with waits

### Coverage
- [ ] Every test case step mapped to VIVIDUS step(s) or marked as gap
- [ ] Coverage percentage calculated
- [ ] Discrepancies documented with impact and recommendations

### Output Quality
- [ ] Meta tags: testCaseId, feature, priority
- [ ] Assumptions marked with `[ASSUMPTION]` comments
- [ ] Discrepancies marked with `[DISCREPANCY]` comments
- [ ] Items requiring validation clearly listed
- [ ] All report sections completed
