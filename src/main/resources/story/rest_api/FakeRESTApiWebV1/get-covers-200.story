Description: GET /api/v1/CoverPhotos/books/covers/{idBook} returns cover photos for a book

Meta:
    @api
    @endpoint GET /api/v1/CoverPhotos/books/covers/{idBook}
    @responseCode 200

Scenario: Retrieving CoverPhotos by book ID returns valid array
!-- Create CoverPhoto first to ensure at least one exists for the book
When I create CoverPhoto with random data
When I execute HTTP GET request for resource with URL `${api-base-url}/api/v1/CoverPhotos/books/covers/${coverBookId}`
Then response code is equal_to `200`
Then JSON `${response}` is valid against schema `${coverPhotoArraySchema}`
Then number of JSON elements from `${response}` by JSON path `$` is greater_than_or_equal_to 1
