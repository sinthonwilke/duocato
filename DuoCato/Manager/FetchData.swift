import Foundation

func fetchData(from url: URL, method: String = "GET", requestBody: [[String: Any]]? = nil) async throws -> Any {
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    if let body = requestBody {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            throw error
        }
    }
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
    }
    
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json
    } catch {
        throw error
    }
}
