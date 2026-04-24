---
name: generate-vividus-api-tests
description: 'Generate VIVIDUS API test automation stories from OpenAPI/Swagger specifications. Creates executable .story files for API endpoints following VIVIDUS syntax and project conventions. Use when: creating API tests, automating REST endpoints, generating test stories from Swagger docs.'
argument-hint: 'Provide OpenAPI specification file path or content...'
---

# Process Overview

1. **Parse** OpenAPI specification automatically
2. **Select** endpoints to automate
3. **Discover** VIVIDUS API capabilities
4. **Design** VIVIDUS API test coverage and structure
5. **Generate** VIVIDUS API stories

---

## Step 1: Parse OpenAPI Specification

### Fetch the Specification

Determine the source of the OpenAPI spec from the user input:

- **URL provided** → Use the MCP Playwright browser tool to navigate to the URL and retrieve the spec content:
  1. Call `mcp_playwright_browser_navigate` with the provided URL
  2. Call `mcp_playwright_browser_snapshot` to capture the page content
  3. Extract the raw JSON/YAML spec from the page content
- **File path provided** → Read the file directly from the workspace using `read_file`
- **Raw content provided** → Use it as-is

**ABORT** if:
- No specification source was provided and no URL can be inferred — ask the user to supply the OpenAPI spec URL or file path
- The MCP Playwright tool is unavailable and no file path or raw content was provided — instruct the user to provide the spec directly

### Parse specification and extract:
- **Base URL**: API server address
- **Endpoints**: All available paths
- **Methods**: GET, POST, PUT, DELETE, PATCH for each path
- **Request schemas**: Parameters, headers, body structure
- **Response schemas**: Status codes, response bodies, headers
- **Authentication**: Security schemes (API key, OAuth, Bearer token)
- **Examples**: Request/response examples if available

**ABORT** further execution if:
- Specification is invalid or cannot be parsed
- Specification format is not supported (only OpenAPI 2.0/3.x supported)

When aborting, explain what is missing and request valid OpenAPI specification.

---

## Step 2: Select Endpoints to Automate

Determine which endpoints to generate tests for based on user input:

### Option A: Full Specification
Generate tests for **all** endpoints when user requests complete coverage.

### Option B: Specific Combinations
Generate tests only for user-specified combinations:
- **Path**: `/api/users`, `/api/products`, etc.
- **Method**: GET, POST, PUT, DELETE, PATCH
- **Response Code**: 200, 201, 400, 401, 404, 500, etc.

**Examples**:
- "Create tests for GET /api/users with 200 and 404 responses"
- "Create tests for all POST methods returning 201"
- "Create tests for /api/orders endpoint, all methods"

---

## Step 3: Discover VIVIDUS API Capabilities

### Logic & Flow Planning

**Before choosing any steps**, plan the logical flow of the API test to ensure correctness.
1. Identify API operations sequence (e.g., "Authenticate", "Create resource", "Retrieve resource", "Update resource", "Delete resource")
2. Ensure request dependencies are handled (e.g., "POST user must succeed before GET user by ID", "Authentication token required before protected endpoints")
   - When testing GET or DELETE for a resource that may not exist, include a **prerequisite POST/creation step** within the same scenario to guarantee the resource exists. Add a `!--` comment explaining the dependency (e.g., `!-- Create order first to ensure it exists for retrieval`).
3. Plan positive and negative scenarios:
   - **Positive**: Valid request → Expected success response (200, 201, 204)
   - **Negative**: Invalid request → Expected error response (400, 401, 403, 404, 409, 500)
4. Verify the test validates failure states correctly (e.g., 404 when resource not found, 401 when unauthorized)

### VIVIDUS API Steps Discovery

1. **MUST** fetch available VIVIDUS API steps by calling the MCP tool matching pattern `vividus_get_all_features`
   - **ABORT** if the VIVIDUS MCP tool is not available or not connected. Instruct the user to connect the VIVIDUS MCP server before proceeding. Without this tool, valid steps cannot be discovered and stories will contain incorrect syntax.
2. Read existing API test patterns:
   - `src/main/resources/story/**/*.story` — existing API stories
   - `src/main/resources/steps/**/*.steps` — reusable composite steps for API testing
3. Learn from examples: HTTP methods, request/response validation, authentication patterns

⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

**Strict rules:**
1. **ONLY use steps returned by the MCP tool matching pattern `vividus_get_all_features`** — NEVER invent, modify, or assume steps
2. **Preserve exact syntax** — do not alter step parameters or structure
3. **If a required step is NOT available** — mark as `!-- [MISSING STEP]` in story
4. **Do not add indentation or formatting** — maintain VIVIDUS step syntax exactly as defined

---

## Step 4: VIVIDUS API Story Guidelines

### General Rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **HTTP Methods:** Support GET, POST, PUT, DELETE, PATCH
3. **Data Tables:** Use Examples blocks for parameterized API tests
4. **Composite Steps:** Reuse existing composite steps for common API patterns
5. **Variables:** Store and reuse response data using VIVIDUS variables
6. **Variable Initialization:** Any literal value (string, number, URL segment, etc.) that appears **more than once** within a story **must** be extracted into a story variable. Initialize it at the top of the story and reference it via `${variableName}` everywhere it is used. When initializing **3 or more story-level variables**, use the table form instead of individual steps:

   ✅ **Good** — table form for 3+ variables:
   ```gherkin
   Given I initialize story variable `<variable>` with value `<value>`
   Examples:
   |variable        |value                          |
   |username        |testuser#{randomInt(10000,99999)}|
   |firstName       |John                           |
   |lastName        |Doe                            |
   |updatedFirstName|Jane                           |
   |updatedLastName |Smith                          |
   ```

   ✅ **Good** — individual steps for 1–2 variables:
   ```gherkin
   Given I initialize story variable `username` with value `testuser#{randomInt(10000,99999)}`
   ```

   ❌ **Avoid** — individual steps for 3+ variables (verbose and harder to read)

### API Test Structure

**Each endpoint check must be a separate scenario.** The scenario name must describe the specific check being performed (e.g., `Scenario: Verify GET /api/v1/Activities returns list of activities` or `Scenario: Verify POST /api/v1/Activities creates new activity`). Do not combine multiple endpoint checks into a single scenario.

Each API test scenario should follow this pattern:

1. **Setup**: Configure base URL, headers, authentication
2. **Request**: Execute HTTP method with parameters/body
3. **Validation**: Verify status code, response body, headers
4. **Cleanup**: (if needed) Delete created resources

### Authentication Handling

Support common authentication methods from OpenAPI specification:
- **API Key**: Header or query parameter
- **Bearer Token**: Authorization header
- **Basic Auth**: Username/password
- **OAuth2**: Token-based authentication

**Example**:

```gherkin
Given I initialize story variable `apiKey` with value `#{envVars.API_KEY}`
When I set request headers:
|name          |value           |
|Authorization |Bearer ${apiKey}|
```

### Request Body Handling

For POST/PUT/PATCH requests with JSON bodies:

✅ **Good** - inline JSON for simple bodies:

```gherkin
Given request body: {"name": "Test User", "email": "test@example.com"}
```

### Response Validation

Always validate at minimum:
1. **Status code**: Verify expected HTTP status
2. **Response schema**: Check structure matches OpenAPI spec using `Then JSON \`$json\` is valid against schema \`$schema\``
3. **Field values**: Validate every field that was set or modified by the test (created, updated, or generated values must be asserted in the response)

**Example**:

```gherkin
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.id` is equal to 1
Then JSON element value from `${response}` by JSON path `$.name` is equal to `Test User`
```

**Response schema validation example**:

```gherkin
Then JSON `${response}` is valid against schema `{
  "type": "object",
  "required": ["id", "title", "dueDate", "completed"],
  "properties": {
    "id":        {"type": "integer"},
    "title":     {"type": ["string", "null"]},
    "dueDate":   {"type": "string"},
    "completed": {"type": "boolean"}
  }
}`
```

**Post-update eventual consistency verification example**:

After a PUT/PATCH operation, use the waiter step to poll until the updated field is reflected in the response. The substep table must contain the GET request to re-fetch the resource:

```gherkin
!-- Wait until the updated field appears in the GET response
When I wait for presence of element by `$.[?(@.firstName=='Updated')]` for `PT60S` duration retrying 15 times
|step|
|When I execute HTTP GET request for resource with relative URL `/v2/user/${petstore.test.username}`|
```

**Post-delete absence verification example**:

After a DELETE operation, use the waiter step to poll until the resource returns `404`. The substep table must contain the GET request to re-fetch the resource:

```gherkin
!-- Wait until the deleted resource returns 404
When I wait for response code `404` for `PT15S` duration retrying 5 times
|step|
|When I execute HTTP GET request for resource with relative URL `/v2/user/${petstore.test.username}`|
```

### Parameterization with Examples

Use Examples tables for testing multiple scenarios:

```gherkin
Scenario: Verify GET /api/users with different status codes
When I execute HTTP GET request for resource with relative URL `/api/users/<userId>`
Then response code is equal to `<statusCode>`
Examples:
|userId|statusCode|
|123   |200       |
|999   |404       |
|abc   |400       |
```

---

## Step 5: Generate VIVIDUS API Story

### Output Folder Structure

Create folder for generated API tests:

```text
src/main/resources/story/rest_api/[endpoint-name].story
```

**ServiceName**: Derive from `info.title` in the OpenAPI spec. Use PascalCase with spaces removed. Example: `"Swagger Petstore"` → `SwaggerPetstore`, `"User Management API"` → `UserManagementAPI`.

**DO NOT create:**
- Summary reports
- README files
- Additional documentation
- Any markdown files

### Story File Structure

**Location**: `src/main/resources/story/rest_api/[endpoint-name].story`

**Meta Tag Guidelines for API Tests**:

| Tag        | Format                   | Description                                |
|------------|--------------------------|--------------------------------------------|
| `@api`     | Fixed                    | Marks as API test                          |
| `@service` | `@service [ServiceName]` | API service name derived from OpenAPI spec |

**Naming Convention**:
- File: `[method]-[resource]-[status].story`
- `[resource]` is the **last meaningful path segment** (exclude path parameters):
  - `/store/inventory` → `inventory`
  - `/store/order` → `order`
  - `/store/order/{orderId}` → `order` (ignore `{orderId}`)
  - `/pet/{petId}/uploadImage` → `uploadImage`
- Examples: `get-inventory-200.story`, `post-order-200.story`, `get-order-404.story`

## Re-executability Policy:

Every generated story **MUST** be re-executable — running the same story multiple times must always produce the same result.

1. **No hardcoded IDs or credentials**: Never hardcode dynamic or environment-specific values — this includes resource IDs, titles, credentials, and base URLs.
   - **IDs**: Never reference a fixed resource ID (e.g., `id: 5`) in assertions or URL paths. Always create the resource within the same story and save the returned ID to a story-scoped variable (e.g., `Then save JSON element value from \`${response}\` by JSON path \`$.id\` to story variable \`createdId\``), then reference it as `${createdId}`.
   - **Credentials & URLs**: Never hardcode usernames, passwords, tokens, or base URLs. Always reference them via properties variables (e.g., `${vividus.web.url}`, `${username}`, `${token}`).
2. **No hardcoded timestamps**: Use dynamic expressions or variables for date/time values, not static strings.
3. **Self-contained scenarios**: Each scenario must set up everything it needs (creation of prerequisite resources) and clean up after itself (deletion of created resources).
4. **Isolated state**: A scenario must not depend on data left by a previous run.
5. **Intra-story dependencies allowed**: A scenario within a story may depend on data produced by an earlier scenario in the same story (e.g., an ID saved to a story-scoped variable by a POST scenario and reused in a subsequent GET/PUT/DELETE scenario). Use `story` variable scope for such shared data. Add a `!--` comment in the dependent scenario explaining which scenario it depends on.
