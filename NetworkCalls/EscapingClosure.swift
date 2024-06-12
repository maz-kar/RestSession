//
//  EscapingClosure.swift
//  NetworkCalls
//
//  Created by Maziar Layeghkar on 17.03.24.
//

import SwiftUI

struct DownloadEscapingModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class DownloadEscapingViewModel: ObservableObject {
    @Published var posts: [DownloadEscapingModel] = []
    
    init() {
        getPosts()
    }

    func getPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        downloadData(fromURL: url) { returnedData in
            if let data = returnedData {
                //As the new URL was with the type of array, we have to change our decode to []
                guard let newPost = try? JSONDecoder().decode([DownloadEscapingModel].self, from: data) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.posts = newPost
                }
            } else {
                print("There is not returned data.")
            }
        }
    }

    func downloadData(fromURL url: URL, completionHandler: @escaping (_ data: Data?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300
            else {
                print("Error downloading data.")
                completionHandler(nil)
                return
            }
            completionHandler(data)
        }.resume()
    }
}

struct DownloadEscapingView: View {
    @StateObject var viewModel = DownloadEscapingViewModel()
    var body: some View {
        List {
            ForEach(viewModel.posts) { post in
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    DownloadEscapingView()
}

