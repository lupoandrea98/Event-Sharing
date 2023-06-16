import SwiftUI

struct Explore: View {
    @ObservedObject var model: EventModelData
   
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //Color("Background") // Colore di sfondo per tutto il contenuto della vista
                NavigationView {
                    List {
                        ForEach(model.categories!.keys.sorted(), id: \.self) {
                            key in
                            CategoryRow(categoryName: key, events: model.categories![key]!)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.bottom, 10)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .listStyle(.grouped)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack {
                                Text("Explore Events")
                                    .font(Font(UIFont(name: "Helvetica-Bold", size: 25)!))
                                    .foregroundColor(Color.blue)
                            }
                        }
                    }
                    
                }
            }
                
        }
    }
}

//struct Explore_Previews: PreviewProvider {
//    static var previews: some View {
//        Explore()
//    }
//}

class EventModelData: ObservableObject {
    @Published var categories: [String : [Event]]?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateExploreEvents), name: Notification.Name("eventsModified"), object: nil)
    }
    
    @objc func updateExploreEvents() {
        categories = {
            guard let events = PresenterManager.homePresenter?.allEvents else { return [:] }
            return Dictionary(grouping: events, by: {$0.tag})
        }()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

