Description: CRUD lifecycle tests for /api/v1/Books resource (FakeRESTApi.Web V1)

Meta:
@api
@endpoint POST /api/v1/Books
@responseCode 200

Scenario: Verify full CRUD lifecycle for Books
!-- Step 1: GET list of books to verify the API is available
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Books`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$` is greater than 0

!-- Step 2: POST a new book and validate response body. FakeRESTApi does not persist data - do NOT reuse returned ID
When I create FakeRESTApiWebV1 book with title `Test Book #{generate(bothify 'title_###??')}` and description `Test description #{randomInt(1000, 9999)}` and pageCount `#{randomInt(100, 500)}`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.id` is equal to 1
Then number of JSON elements from `${response}` by JSON path `$.title` is equal to 1
Then number of JSON elements from `${response}` by JSON path `$.description` is equal to 1

!-- Step 3: GET existing book by fixed ID=1 (FakeRESTApi always seeds this data)
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Books/1`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `1`
Then number of JSON elements from `${response}` by JSON path `$.title` is equal to 1

!-- Step 4: PUT to update book with ID=1
When I update FakeRESTApiWebV1 book with ID `1` and title `Updated Book #{generate(bothify 'title_###??')}` and description `Updated description` and pageCount `#{randomInt(100, 500)}`
Then response code is equal to `200`

!-- Step 5: GET book again after update (FakeRESTApi does not persist updates, ID=1 always returns 200)
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Books/1`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `1`

!-- Step 6: DELETE book with ID=1
When I execute HTTP DELETE request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Books/1`
Then response code is equal to `200`
