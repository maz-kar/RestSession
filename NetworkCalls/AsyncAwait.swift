//
//  AsyncAwait.swift
//  NetworkCalls
//
//  Created by Maziar Layeghkar on 17.03.24.
//

import SwiftUI

struct AsyncAwaitDownloadModel: Codable {
    let avatarUrl: String
    let login: String
    let bio: String
}


class AsyncAwaitDownloadViewModel: ObservableObject {
    @Published var model: AsyncAwaitDownloadModel?
    
    func getPosts() async throws -> AsyncAwaitDownloadModel {
        guard let url = URL(string: "https://api.github.com/users/maz-kar") else { throw GHError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw GHError.invalidResponse }
        
        do {
            let decoderData = JSONDecoder()
            decoderData.keyDecodingStrategy = .convertFromSnakeCase
            return try decoderData.decode(AsyncAwaitDownloadModel.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

struct AsyncAwaitDownloadView: View {
    @StateObject var viewModel = AsyncAwaitDownloadViewModel()
    @State private var user: AsyncAwaitDownloadModel?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundStyle(Color.gray)
            }
            .frame(width: 120, height: 120)
            
            Text(user?.login ?? "Username")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "Bio of each user will be here. I am trying to make it two lines")
        }
        .padding()
        Spacer()
            .task {
                do {
                    user = try await viewModel.getPosts()
                } catch GHError.invalidURL {
                    print("Invalid URL")
                } catch GHError.invalidResponse {
                    print("Invalid response")
                } catch GHError.invalidData {
                    print("Invalid Data")
                } catch {
                    print("Unexpected Error")
                }
            }
    }
}

#Preview {
    AsyncAwaitDownloadView()
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

