Description: CRUD operations for the Pet resource of the Swagger Petstore API

Meta:
    @api
    @resource pet

Scenario: Create a new pet via POST /pet
Meta:
    @endpoint POST /pet
    @responseCode 200
Given I initialize story variable `petName` with value `#{generate(Name.firstName)}`
Given I initialize story variable `categoryId` with value `#{generate(numerify '###')}`
Given I initialize story variable `categoryName` with value `#{generate(Name.firstName)}`
Given I initialize story variable `tagId` with value `#{generate(numerify '###')}`
Given I initialize story variable `tagName` with value `#{generate(Name.firstName)}`
Given I initialize story variable `photoUrl` with value `https://example.com/photo.jpg`
When I set request headers:
|name        |value           |
|Content-Type|application/json|
|Accept      |application/json|
Given request body: {
    "category": { "id": ${categoryId}, "name": "${categoryName}" },
    "name": "${petName}",
    "photoUrls": ["${photoUrl}"],
    "tags": [{ "id": ${tagId}, "name": "${tagName}" }],
    "status": "available"
}
When I execute HTTP POST request for resource with URL `${petStoreRestApi}/pet`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `#{loadResource(/data/schemas/SwaggerPetstore/pet.json)}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${petName}`
Then JSON element value from `${response}` by JSON path `$.status` is equal to `available`
Then JSON element value from `${response}` by JSON path `$.photoUrls[0]` is equal to `${photoUrl}`
Then JSON element value from `${response}` by JSON path `$.category.name` is equal to `${categoryName}`
Then JSON element value from `${response}` by JSON path `$.tags[0].name` is equal to `${tagName}`
When I save JSON element value from `${response}` by JSON path `$.id` to story variable `petId`


Scenario: Retrieve the created pet via GET /pet/{petId}
Meta:
    @endpoint GET /pet/{petId}
    @responseCode 200
When I set request headers:
|name  |value           |
|Accept|application/json|
When I execute HTTP GET request for resource with URL `${petStoreRestApi}/pet/${petId}`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `#{loadResource(/data/schemas/SwaggerPetstore/pet.json)}`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `${petId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${petName}`
Then JSON element value from `${response}` by JSON path `$.status` is equal to `available`
Then JSON element value from `${response}` by JSON path `$.photoUrls[0]` is equal to `${photoUrl}`
Then JSON element value from `${response}` by JSON path `$.category.id` is equal to `${categoryId}`
Then JSON element value from `${response}` by JSON path `$.category.name` is equal to `${categoryName}`
Then JSON element value from `${response}` by JSON path `$.tags[0].id` is equal to `${tagId}`
Then JSON element value from `${response}` by JSON path `$.tags[0].name` is equal to `${tagName}`


Scenario: Update the existing pet via PUT /pet
Meta:
    @endpoint PUT /pet
    @responseCode 200
Given I initialize scenario variable `updatedName` with value `#{generate(Name.firstName)}`
Given I initialize scenario variable `updatedStatus` with value `sold`
When I set request headers:
|name        |value           |
|Content-Type|application/json|
|Accept      |application/json|
Given request body: {
    "id": ${petId},
    "category": { "id": ${categoryId}, "name": "${categoryName}" },
    "name": "${updatedName}",
    "photoUrls": ["${photoUrl}"],
    "tags": [{ "id": ${tagId}, "name": "${tagName}" }],
    "status": "${updatedStatus}"
}
When I execute HTTP PUT request for resource with URL `${petStoreRestApi}/pet`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `#{loadResource(/data/schemas/SwaggerPetstore/pet.json)}`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `${petId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${updatedName}`
Then JSON element value from `${response}` by JSON path `$.status` is equal to `${updatedStatus}`
!-- Confirm the update is persisted by re-fetching the resource and asserting new values
When I execute HTTP GET request for resource with URL `${petStoreRestApi}/pet/${petId}`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `${petId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${updatedName}`
Then JSON element value from `${response}` by JSON path `$.status` is equal to `${updatedStatus}`


Scenario: Delete the pet via DELETE /pet/{petId}
Meta:
    @endpoint DELETE /pet/{petId}
    @responseCode 200
When I execute HTTP DELETE request for resource with URL `${petStoreRestApi}/pet/${petId}`
Then response code is equal to `200`
!-- Verify the pet no longer exists after deletion
When I execute HTTP GET request for resource with URL `${petStoreRestApi}/pet/${petId}`
Then response code is equal to `404`
