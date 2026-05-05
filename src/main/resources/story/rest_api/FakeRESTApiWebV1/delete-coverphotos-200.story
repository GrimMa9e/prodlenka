Description: DELETE /api/v1/CoverPhotos/{id} removes a cover photo

Meta:
    @api
    @endpoint DELETE /api/v1/CoverPhotos/{id}
    @responseCode 200

Scenario: Deleting CoverPhoto removes resource
!-- Create CoverPhoto first to ensure it exists for deletion
When I create CoverPhoto with random data
When I execute HTTP DELETE request for resource with URL `${api-base-url}/api/v1/CoverPhotos/${coverId}`
Then response code is equal_to `200`
!-- Verify resource no longer exists
When I execute HTTP GET request for resource with URL `${api-base-url}/api/v1/CoverPhotos/${coverId}`
Then response code is equal_to `404`
