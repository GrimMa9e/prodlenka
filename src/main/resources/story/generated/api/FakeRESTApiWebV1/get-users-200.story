Description: Verify GET Users list returns 200 and array of users

Meta:
    @api
    @endpoint GET /api/v1/Users
    @responseCode 200

Scenario: Verify GET /api/v1/Users returns list of users
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `{"type":"array","items":{"type":"object","required":["id","userName","password"],"properties":{"id":{"type":"integer"},"userName":{"type":"string"},"password":{"type":"string"}},"additionalProperties":false}}`
Then number of JSON elements from `${response}` by JSON path `$` is equal to 10
Then JSON element value from `${response}` by JSON path `$[0].id` is equal to `1`
Then JSON element value from `${response}` by JSON path `$[0].userName` is equal to `User 1`
