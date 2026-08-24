//
//  SearchBarView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 26/04/25.
//

import SwiftUI

struct ProgrammingLanguage: Identifiable {
   let id = UUID()
   let name: String
}

struct SearchBarView: View {
    @State var title : String = "Search Bar"
    @State private var searchData: String = ""
    let lang: [ProgrammingLanguage] = [
          ProgrammingLanguage(name: "C"),
          ProgrammingLanguage(name: "C++"),
          ProgrammingLanguage(name: "Java"),
          ProgrammingLanguage(name: "Python"),
          ProgrammingLanguage(name: "C#"),
          ProgrammingLanguage(name: "Swift"),
          ProgrammingLanguage(name: "Go"),
          ProgrammingLanguage(name: "Ruby"),
          ProgrammingLanguage(name: "Scala"),
          ProgrammingLanguage(name: "JavaScript"),
          ProgrammingLanguage(name: "JQuery"),
          ProgrammingLanguage(name: "Objective-C")
       ]
    
    var filteredLang: [ProgrammingLanguage] {
        lang.filter { searchData.isEmpty || $0.name.localizedCaseInsensitiveContains(searchData) }
    }

    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: true)
            ZStack {
                VStack {
                    HStack {
                        Image (systemName: "magnifyingglass").padding(.leading)
                        TextField("Search", text: $searchData).padding(.trailing)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                        if searchData != "" {
                            Image(systemName: "xmark.circle.fill").padding(.trailing).onTapGesture {
                                searchData = ""
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.leading).padding(.trailing)
                    
                    if self.filteredLang.isEmpty {
                        Image (systemName: "magnifyingglass").resizable().frame(width: 44, height: 44).padding().foregroundColor(.gray)
                        Text("No data found!")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    else {
                        List {
                            ForEach(self.filteredLang) { language in
                                Text(language.name)
                            }
                        }.listStyle(PlainListStyle())
                    }
                }
            }
            Spacer()
        }
    }
}

#Preview {
    SearchBarView()
}
