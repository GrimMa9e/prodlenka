---
name: generate-vividus-api-tests
description: 'Generate VIVIDUS API test automation stories from OpenAPI/Swagger specifications. Creates executable .story files for API endpoints following VIVIDUS syntax and project conventions. Use when: creating API tests, automating REST endpoints, generating test stories from Swagger docs.'
argument-hint: 'Provide OpenAPI specification file path or content...'
---

# Process Overview

1. **Parse** OpenAPI specification
2. **Select** endpoints to automate
3. **Discover** VIVIDUS API capabilities
4. **Design** VIVIDUS API test coverage and structure
5. **Generate** VIVIDUS API stories

---

## Step 1: Parse OpenAPI Specification

**Required Input**: OpenAPI/Swagger specification (file path or content)

Before parsing, automatically fetch OpenAPI spec from provided URL using HTTP GET.

### Parse specification and extract:
- **Base URL**: API server address
- **Endpoints**: All available paths
- **Methods**: GET, POST, PUT, DELETE, PATCH for each path
- **Request schemas**: Parameters, headers, body structure
- **Response schemas**: Status codes, response bodies, headers
- **Authentication**: Security schemes (API key, OAuth, Bearer token)
- **Examples**: Request/response examples if available

**ABORT** further execution if:
- OpenAPI specification is not provided
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
4. **Composite Steps:** Reuse existing composite steps for common API patterns. Only create a new composite step when it groups **two or more** basic steps — never create a composite step that wraps a single basic step.
5. **Variables:** Store and reuse response data using VIVIDUS variables
6. **No Hardcoded Values:** Use random generators like `#{randomInt(100000, 999999)}` and `#{generate(bothify 'prefix_###??')}` for IDs and test data.
7. **Request Headers:** Always set Content-Type: application/json before POST/PUT/PATCH requests.

### CRUD Lifecycle in ONE story
Create a single story with full CRUD cycle: POST → GET → PUT → GET → DELETE → GET
This ensures re-executability and independence.

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
2. **Response schema**: Check structure matches OpenAPI spec
3. **Critical fields**: Validate key response values
4. **After DELETE**: Call GET on the deleted resource and expect a 404 or 410 response.

**Example**:

```gherkin
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.id` is equal to 1
Then JSON element value from `${response}` by JSON path `$.name` is equal to `Test User`
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

Create composite steps in: `src/main/resources/steps/api/[resource].steps`

**ServiceName**: Derive from `info.title` in the OpenAPI spec. Use PascalCase with spaces removed. Example: `"Swagger Petstore"` → `SwaggerPetstore`, `"User Management API"` → `UserManagementAPI`.

**DO NOT create:**
- Summary reports
- README files
- Additional documentation
- Any markdown files

### Story File Structure

**Location**: `src/main/resources/story/rest_api/[endpoint-name].story`

**Meta Tag Guidelines for API Tests**:

| Tag | Format | Description |
|-----|--------|-------------|
| `@api` | Fixed | Marks as API test |
| `@endpoint` | `GET /api/users` | HTTP method + path |
| `@responseCode` | `200`, `404`, `500` | Expected status code |

**Naming Convention**:
- File: `[method]-[resource]-[status].story`
- `[resource]` is the **last meaningful path segment** (exclude path parameters):
  - `/store/inventory` → `inventory`
  - `/store/order` → `order`
  - `/store/order/{orderId}` → `order` (ignore `{orderId}`)
  - `/pet/{petId}/uploadImage` → `uploadImage`
- Examples: `get-inventory-200.story`, `post-order-200.story`, `get-order-404.story`

---

## Known API Examples

### FakeRESTApi (https://fakerestapi.azurewebsites.net)

Test strategy for Books:

1. **GET /Books** → get list, use first existing ID (e.g. `1`)
2. **POST /Books** → validate 200 and response body. Do NOT reuse returned ID.
3. **GET /Books/1** → validate 200
4. **PUT /Books/1** → validate 200
5. **DELETE /Books/1** → validate 200
