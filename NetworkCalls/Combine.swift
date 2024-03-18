//
//  Combine.swift
//  NetworkCalls
//
//  Created by Maziar Layeghkar on 17.03.24.
//

import SwiftUI
import Combine

//Combine Discussion:
/*
 // 1. sign up for monthly subscription for package to be delivered
 // 2. the company would make the package behind the scene
 // 3. recieve the package at your front door
 // 4. make sure the box isn't damaged
 // 5. open and make sure the item is correct
 // 6. use the item!!!!
 // 7. cancellable at any
 
 // 1. create the publisher
 // 2. subscribe publisher on background thread
 // 3. recieve on main thread
 // 4. tryMap (check that the data is good)
 // 5. decode (decode data into PostModels)
 // 6. sink (put the item into our app)
 // 7. store (cancel subscription if needed)
 */

struct DownloadJSONCombineModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class DownloadJSONCombineViewModel: ObservableObject {
    @Published var posts: [DownloadJSONCombineModel] = []
    var cancellable = Set<AnyCancellable>()
    init() {
        getData()
    }
    
    func getData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
            .decode(type: [DownloadJSONCombineModel].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .sink(receiveValue: { [weak self] returnedPosts in
                self?.posts = returnedPosts
            })
            .store(in: &cancellable)
    }
    
    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return output.data
    }
}

struct DownloadJSONCombineView: View {
    @StateObject var viewModel = DownloadJSONCombineViewModel()
    var body: some View {
        List {
            ForEach(viewModel.posts) { post in
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
        }
    }
}

#Preview {
    DownloadJSONCombineView()
}
