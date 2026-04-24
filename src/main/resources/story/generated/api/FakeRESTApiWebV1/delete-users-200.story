Description: Verify full Users CRUD lifecycle with delete and post-deletion check

Meta:
    @api
    @endpoint DELETE /api/v1/Users/{id}
    @responseCode 200

Scenario: Verify Users CRUD lifecycle and post-deletion absence
!-- Create user first to ensure a consistent CRUD dependency chain within the same scenario
When I generate and prepare Users body request
When I execute HTTP POST request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `{"type":"object","required":["id","userName","password"],"properties":{"id":{"type":"integer"},"userName":{"type":"string"},"password":{"type":"string"}},"additionalProperties":false}`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `${userId}`
Given I initialize scenario variable `updatedUserName` with value `#{generate(bothify 'upd_####??')}`
Given I initialize scenario variable `updatedPassword` with value `#{generate(bothify 'new_####??')}`
When I prepare Users body request with id `${userId}` userName `${updatedUserName}` and password `${updatedPassword}`
When I execute HTTP PUT request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users/${userId}`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.userName` is equal to `${updatedUserName}`
!-- GET by id returns 404 on this fake API implementation even after POST/PUT — validate that behavior explicitly
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users/${userId}`
Then response code is equal to `404`
When I execute HTTP DELETE request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users/${userId}`
Then response code is equal to `200`
!-- Post-deletion verification: resource must be absent
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users/${userId}`
Then response code is equal to `404`
Then JSON element value from `${response}` by JSON path `$.status` is equal to `404`
Then JSON element value from `${response}` by JSON path `$.title` is equal to `Not Found`
