---
name: generate-vividus-api-tests
description: 'Generate VIVIDUS API test automation stories from OpenAPI/Swagger specifications. Creates executable .story files for API endpoints following VIVIDUS syntax and project conventions. Use when: creating API tests, automating REST endpoints, generating test stories from Swagger docs.'
argument-hint: 'Provide OpenAPI specification file path or content...'
---

# Process Overview

1. **Retrieve** OpenAPI specification automatically
2. **Parse** OpenAPI specification
3. **Select** endpoints to automate
4. **Discover** VIVIDUS API capabilities
5. **Design** VIVIDUS API test coverage and structure
6. **Generate** VIVIDUS API stories

---

## Step 0: Retrieve OpenAPI Specification Automatically

**BEFORE creating any tests**, the OpenAPI specification must be retrieved automatically (not manually added to the prompt).

### How to retrieve the specification:

1. **Determine the OpenAPI URL**:
   - Check `src/main/resources/overriding.properties` (or any relevant profile properties file) for a variable defining the OpenAPI spec URL (e.g., `openapi.url`, `swagger.url`, or similar).
   - If such a variable exists, use its value as `OPENAPI_URL`.
   - If no variable is found, ask the user to provide the OpenAPI spec URL before proceeding.

2. **Run the prepare-openapi.sh script** to automatically download and validate the OpenAPI spec:
   ```bash
   ./scripts/prepare-openapi.sh [OPENAPI_URL] [OUTPUT_FILE]
   ```

   **Parameters**:
   - `OPENAPI_URL`: URL to the OpenAPI/Swagger specification (resolved in step 1 above).
   - `OUTPUT_FILE` (optional): Path where the spec will be saved. Defaults to `./output/openapi/latest-openapi.json`

3. **Validate the output**: The script automatically validates that the downloaded file contains a valid OpenAPI/Swagger document. If validation fails, the script will abort with an error.

4. **Use the retrieved specification**: The downloaded spec is now available at the output path and must be used for all subsequent test generation and validation steps.

**DO NOT proceed** if:
- The OpenAPI URL cannot be determined from properties files and the user has not provided it
- The specification file does not exist
- The specification cannot be parsed
- The specification is not a valid OpenAPI 2.0 or 3.x document

---

## Step 1: Parse OpenAPI Specification

**Required Input**: OpenAPI/Swagger specification (file path or content)

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
   - **CRUD sequence with story variables (preferred):** When a story covers the full CRUD lifecycle (POST → GET → PUT → DELETE) for the same resource, the POST/Create scenario must save the created resource's ID and all key generated values as **story variables**. All subsequent GET, PUT, and DELETE scenarios within the same story must reuse those story variables — they must NOT create new resources, must NOT use `!--` prerequisite comments, and must NOT re-initialise already-generated values.
   - **Standalone prerequisite (fallback):** Only include an in-scenario prerequisite POST if the story does NOT contain a preceding create scenario (e.g. a story that tests only GET and DELETE in isolation). In that case add a `!--` comment explaining the dependency (e.g., `!-- Create order first to ensure it exists for retrieval`).
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
5. **NEVER use `is not equal to` as a comparison rule** — `StringComparisonRule` does not support `IS_NOT_EQUAL_TO` and will throw a runtime conversion error. Use one of these alternatives instead:
   - To verify a field **changed to a new value**: assert the new value with `is equal to`.
   - To verify a field or element is **absent** from the response: use `Then number of JSON elements from \`${response}\` by JSON path \`$.fieldName\` is equal to \`0\``.

---

## Step 4: VIVIDUS API Story Guidelines

### General Rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **HTTP Methods:** Support GET, POST, PUT, DELETE, PATCH
3. **Data Tables:** Use Examples blocks for parameterized API tests
4. **Composite Steps:** Reuse existing composite steps for common API patterns
5. **Variables:** Store and reuse response data using VIVIDUS variables
6. **Tests must be fully re-executable and must not contain any hardcoded test data values.** Use `#{generate(...)}` expressions (e.g., `#{generate(Name.firstName)}` for a pet name, `#{generate(numerify '###')}` for a category ID) to generate dynamic data at runtime. Always save generated values to a variable **before** the request so they can be asserted in the response.
7. **Tests must validate the response schema against the current OpenAPI specification.**
8. **Tests must verify the values of all fields that are generated or updated during the test.** After a successful PUT or PATCH, use a GET request to retrieve the updated resource and assert that each changed field matches the expected value.
9. **Tests must check that an object is absent after it has been deleted.** After a successful DELETE on a **persisting API**, perform a GET for the same resource ID and assert the response code is `404`.

### API Test Structure

Each API test scenario should follow this pattern:

1. **Setup**: Configure base URL, headers, authentication
   - Always use variables from properties files (e.g., `${petStoreRestApi}`, `${petStoreRestApi}/pet/${petId}`) instead of hardcoding endpoint URLs
   - Check `src/main/resources/overriding.properties` or relevant profile for variable definitions
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

### Dynamic Data Generation

**Common generators:**

| Data type | Expression | Example output |
|---|---|---|
| First name | `#{generate(Name.firstName)}` | `James` |
| Last name | `#{generate(Name.lastName)}` | `Wilson` |
| N-digit number string | `#{generate(Number.digits '7')}` | `3847291` |
| Patterned number | `#{generate(numerify '###')}` | `482` |
| Password-like string | `#{generate(Internet.password '5','10','true')}` | `aB3#x7` |

Initialize story variables before the request and save the created resource ID for reuse across scenarios:

```gherkin
Given I initialize story variable `petName` with value `#{generate(Name.firstName)}`
Given request body: {"name": "${petName}", "photoUrls": ["https://example.com/photo.jpg"], "status": "available"}
When I execute HTTP POST request for resource with relative URL `/pet`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${petName}`
When I save JSON element value from `${response}` by JSON path `$.id` to story variable `petId`
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
2. **Response schema**: Check structure matches OpenAPI spec — reference an external schema file, not an inline string
3. **Critical fields**: Validate key response values

#### JSON Schema Files

Store schema files under `src/main/resources/data/schemas/[ServiceName]/`:

```text
├── [resource].json          # single-object schema
└── [resource]-list.json     # array schema for list endpoints
```

Reference using `#{loadResource(...)}` — do **not** inline schemas as strings:

```gherkin
Then JSON `${response}` is valid against schema `#{loadResource(/data/schemas/SwaggerPetstore/pet.json)}`
```

**Example schema file** (`pet.json`):

```json
{
  "type": "object",
  "properties": {
    "id": { "type": "integer" },
    "category": {
      "type": ["object", "null"],
      "properties": {
        "id": { "type": "integer" },
        "name": { "type": ["string", "null"] }
      }
    },
    "name": { "type": "string" },
    "photoUrls": {
      "type": "array",
      "items": { "type": "string" }
    },
    "tags": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "integer" },
          "name": { "type": ["string", "null"] }
        }
      }
    },
    "status": { "type": ["string", "null"] }
  },
  "required": ["id", "name", "photoUrls"]
}
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
src/main/resources/story/generated/api/[ServiceName]/
└── [ServiceName].story     # VIVIDUS API story file
```

**One endpoint → one story file:** one `.story` file per endpoint path, covering all HTTP methods. Multiple response codes stay as scenarios/examples within the same file — do not split by method, response code, or combine different paths.

**DO NOT create:**
- Summary reports
- README files
- Additional documentation
- Any markdown files

### Story File Structure

**Location**: `src/main/resources/story/generated/api/[ServiceName]/[ServiceName].story`

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
