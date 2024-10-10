#  Witch Hat

<img src="Sources/Media.xcassets/witchhat.imageset/witchhat.png" width="300" alt="Witch Hat Logo">
So lean it's emaciated. So lightweight it flies.
<br><br>
Witch Hat is a Swift networking library for developers bored of writing the same networking code for every new project.
<br>
- Flexible, type-safe and extensible
<br>
- Lightweight with zero dependencies
<br>
- Uses actors and async/await for thread-safety

## Features

- Custom Endpoints: Define reusable and modular API endpoints with customizable HTTP methods, headers, query items, and body data.
- Token-Based Authentication: Built-in support for managing token-based authentication with automatic token refresh.
- Grouped Endpoints: Organize related endpoints with shared base URLs.
- Error Handling: Handle network errors, decoding issues, and token refresh failures with detailed error types.

## Installation

Swift Package Manager (SPM)

Add the following dependency to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/coreybb/WitchHat.git", from: "1.0.0")
]
```

Then, add it as a dependency to your target:
```swift
.target(
    name: "YourTargetName",
    dependencies: ["WitchHat"]
)
```

## Usage Examples

#### Example 1: Basic GET Request

Make a simple GET request to retrieve user data using a custom endpoint.

```swift
import WitchHat

struct UserEndpoint: GroupedEndpoint {
    typealias Group = APIGroup
    var path: String? = "users/123"
    var method: HTTPMethod = .get
}

enum APIGroup: EndpointGroup {
    static let baseURL = URL(string: "https://api.example.com")!
}

class UserService: LazyNetworkingService {
    func fetchUser() async throws -> User {
        let endpoint = UserEndpoint()
        return try await request(endpoint)
    }
}

// Usage
let userService = UserService(networkClient: URLSession.shared)
Task {
    do {
        let user: User = try await userService.fetchUser()
        print("User name: \(user.name)")
    } catch {
        print("Failed to fetch user: \(error)")
    }
}
```

#### Example 2: POST Request with JSON Body

Make a POST request with a JSON-encoded body using a custom Endpoint.

```swift
import WitchHat

struct CreatePostEndpoint: GroupedEndpoint {
    typealias Group = APIGroup
    var path: String? = "posts"
    var method: HTTPMethod = .post
    var body: CreatePostRequestBody?

    init(body: CreatePostRequestBody) {
        self.body = body
    }
}

struct CreatePostRequestBody: Encodable {
    let title: String
    let content: String
}

class PostService: LazyNetworkingService {
    func createPost(title: String, content: String) async throws -> Post {
        let body = CreatePostRequestBody(title: title, content: content)
        let endpoint = CreatePostEndpoint(body: body)
        return try await request(endpoint)
    }
}

// Usage
let postService = PostService(networkClient: URLSession.shared)
Task {
    do {
        let newPost = try await postService.createPost(title: "Hello World", content: "This is my first post!")
        print("Created post with ID: \(newPost.id)")
    } catch {
        print("Failed to create post: \(error)")
    }
}
```

#### Example 3: Authentication with Token Refresh

Use AuthenticationServicing to manage token-based authentication with automatic token refresh.

```swift
import WitchHat

struct MyAuthService: AuthenticationServicing {
    private var currentToken: String?
    let networkClient: NetworkDataTransporting
    
    func validToken() async throws -> String {
        if let token = currentToken, !isTokenExpired(token) {
            return token
        } else {
            try await refreshToken()
            guard let newToken = currentToken else {
                throw AuthenticationError.tokenRefreshFailed
            }
            return newToken
        }
    }
    
    func refreshToken() async throws {
        let refreshEndpoint = MyTokenRefreshEndpoint()
        let response: MyTokenResponse = try await request(refreshEndpoint)
        currentToken = refreshEndpoint.extractToken(from: response)
    }
    
    func isTokenExpired(_ token: String) -> Bool {
        // check if the token is expired.
        return false
    }
}

struct MyTokenRefreshEndpoint: TokenRefreshEndpoint {
    typealias TokenResponse = MyTokenResponse
    var baseURL: URL = URL(string: "https://auth.example.com")!
    var path: String? = "refresh"
    var method: HTTPMethod = .post
    var body: MyRefreshRequestBody?
    var tokenLifetime: TimeInterval = 3600
    
    func extractToken(from response: MyTokenResponse) -> String? {
        return response.token
    }
}

class SecureService: LazyNetworkingService, RequestAuthenticating {
    var authService: AuthenticationServicing

    init(authService: AuthenticationServicing) {
        self.authService = authService
        super.init(networkClient: authService.networkClient)
    }

    func fetchSecureData() async throws -> SecureData {
        let endpoint = SecureDataEndpoint()
        return try await request(endpoint)
    }
}
```

#### Example 4: Dynamic Headers and Query Parameters

Add dynamic headers and query parameters to a request.

```swift
struct SearchEndpoint: GroupedEndpoint {
    typealias Group = APIGroup
    var path: String? = "search"
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?

    init(query: String, token: String) {
        queryItems = [URLQueryItem(name: "q", value: query)]
        headers = [HTTPHeader.bearerToken(token)]
    }
}

class SearchService: LazyNetworkingService {
    func search(query: String, token: String) async throws -> [SearchResult] {
        let endpoint = SearchEndpoint(query: query, token: token)
        return try await request(endpoint)
    }
}

// Usage
let searchService = SearchService(networkClient: URLSession.shared)
Task {
    do {
        let results = try await searchService.search(query: "swift networking", token: "your-token")
        print("Found \(results.count) results")
    } catch {
        print("Search failed: \(error)")
    }
}
```

#### Example 5: Handling an Empty Response

Some API endpoints might return an empty response. For now, Witch Hat handles such cases using the EmptyResponse type.

```swift
struct DeleteUserEndpoint: GroupedEndpoint {
    typealias Group = APIGroup
    var path: String? = "users/123"
    var method: HTTPMethod = .delete
}

class UserService: LazyNetworkingService {
    func deleteUser() async throws {
        let endpoint = DeleteUserEndpoint()
        _: EmptyResponse = try await request(endpoint)
        print("User deleted successfully.")
    }
}

// Usage
let userService = UserService(networkClient: URLSession.shared)
Task {
    do {
        try await userService.deleteUser()
    } catch {
        print("Failed to delete user: \(error)")
    }
}
```

## Contributing

We welcome contributions! If you have ideas for features or improvements, feel free to open issues and submit pull requests.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Contact
[Connect with me on LinkedIn.](https://www.linkedin.com/in/coreybeebe)
