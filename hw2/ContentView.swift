//
//  ContentView.swift
//  hw2
//
//  Created by Julian Hoffmann on 13.05.23.
//
import SwiftUI

struct Card: Codable {
    let name: String
    let type: String
    let colors: [String]
}

struct Response<T: Codable>: Codable {
    let cards: [T]
}

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var isLoading = false
    @State private var page = 0
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                if !errorMessage.isEmpty {
                    Text("An Error occured")
                        .foregroundColor(.red)
                        .padding()
                }
                Button(action: loadCards) {
                    Text("Load Cards")
                        .foregroundColor(.white)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                if isLoading {
                    ProgressView()
                        .padding()
                }
                Text("Page: \(page)")
                List(cards, id: \.name) { card in
                    Text(card.name)
                    Text(card.type).font(.footnote)
                    ForEach(card.colors, id: \.self) { color in
                                Text("Color: \(color)").font(.footnote)
                            }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Magic Cards")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
    
    func loadCards() {
        cards = []
        page += 1
        isLoading = true
        errorMessage = ""
        
        let url = URL(string: "https://api.magicthegathering.io/v1/cards?page=\(page)&pageSize=10")!//without a restrected page size the data can't be loaded sometimes
        var request = URLRequest(url: url)
            request.timeoutInterval = 20
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else{return}
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(Response<Card>.self, from: data)
                DispatchQueue.main.async {
                    if response.cards.isEmpty {
                        page = 0
                        loadCards()
                    } else {
                        cards = response.cards.sorted(by: { $0.name < $1.name })
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
            DispatchQueue.main.async {
                isLoading = false
            }
        }.resume()
    }
 }
     
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

