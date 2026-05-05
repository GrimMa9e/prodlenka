Description: Retrieve OpenAPI schema for runtime validation

Meta:
    @api
    @setup

Scenario: Getting schema from OpenAPI specification
When I execute HTTP GET request for resource with URL `${api-base-url}/swagger/v1/swagger.json`
Then response code is equal_to `200`
When I save JSON element from `${response}` by JSON path `$.components.schemas.CoverPhoto` to next_batches variable `coverPhotoSchema`
Given I initialize next_batches variable `coverPhotoArraySchema` with value `{"type":"array","items":${coverPhotoSchema}}`
