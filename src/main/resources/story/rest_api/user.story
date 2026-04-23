Description: Test demoing VIVIDUS capabilities for REST API - CRUD operations for user resource

Meta: @api @service SwaggerPetstore

Scenario: Initialize test data
Given I initialize story variable `<variable>` with value `<value>`
Examples:
|variable        |value                             |
|username        |testuser#{randomInt(10000,99999)} |
|firstName       |John                              |
|lastName        |Doe                               |
|email           |john.doe@test.com                 |
|password        |P@ssw0rd                          |
|phone           |1234567890                        |
|updatedFirstName|Jane                              |
|updatedLastName |Smith                             |

Scenario: Verify POST /user creates a new user
When I set request headers:
|name        |value           |
|Content-Type|application/json|
Given request body: {"id": 0, "username": "${username}", "firstName": "${firstName}", "lastName": "${lastName}", "email": "${email}", "password": "${password}", "phone": "${phone}", "userStatus": 0}
When I execute HTTP POST request for resource with relative URL `/user`
Then response code is equal to `200`

Scenario: Verify GET /user/{username} returns the created user
!-- Depends on "Verify POST /user creates a new user" scenario to create the test user
When I execute HTTP GET request for resource with relative URL `/user/${username}`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `{
  "type": "object",
  "required": ["id", "username", "firstName", "lastName"],
  "properties": {
    "id":         {"type": "integer"},
    "username":   {"type": "string"},
    "firstName":  {"type": "string"},
    "lastName":   {"type": "string"},
    "email":      {"type": "string"},
    "password":   {"type": "string"},
    "phone":      {"type": "string"},
    "userStatus": {"type": "integer"}
  }
}`
Then JSON element value from `${response}` by JSON path `$.username` is equal to `${username}`
Then JSON element value from `${response}` by JSON path `$.firstName` is equal to `${firstName}`
Then JSON element value from `${response}` by JSON path `$.lastName` is equal to `${lastName}`
When I save JSON element from `${response}` by JSON path `$` to story variable `petstore.get.response`

Scenario: Verify PUT /user/{username} updates firstName and lastName
!-- Depends on "Verify GET /user/{username} returns the created user" scenario for the base user object (petstore.get.response)
!-- PUT request body derived from POST response (as retrieved via GET), with firstName and lastName updated
When I patch JSON `${petstore.get.response}` using `[{"op":"replace","path":"/firstName","value":"${updatedFirstName}"},{"op":"replace","path":"/lastName","value":"${updatedLastName}"}]` and save result to story variable `petstore.put.body`
When I set request headers:
|name        |value           |
|Content-Type|application/json|
Given request body: ${petstore.put.body}
When I execute HTTP PUT request for resource with relative URL `/user/${username}`
Then response code is equal to `200`
!-- Wait until the updated firstName appears in the GET response
When I wait for presence of element by `$.[?(@.firstName=='${updatedFirstName}')]` for `PT60S` duration retrying 15 times
|step|
|When I execute HTTP GET request for resource with relative URL `/user/${username}`|
Then JSON element value from `${response}` by JSON path `$.firstName` is equal to `${updatedFirstName}`
Then JSON element value from `${response}` by JSON path `$.lastName` is equal to `${updatedLastName}`

Scenario: Verify DELETE /user/{username} removes the user
!-- Depends on "Verify POST /user creates a new user" scenario for the test username
When I execute HTTP DELETE request for resource with relative URL `/user/${username}`
Then response code is equal to `200`
!-- Wait until the deleted resource returns 404
When I wait for response code `404` for `PT15S` duration retrying 5 times
|step|
|When I execute HTTP GET request for resource with relative URL `/user/${username}`|
