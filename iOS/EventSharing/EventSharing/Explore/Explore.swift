import SwiftUI

struct Explore: View {
    @ObservedObject var model: EventModelData
   
    var body: some View {
        if model.finish {
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
        } else {
            Text("Wait till all events are downloaded")
                .font(Font(UIFont(name: "Helvetica-Bold", size: 20)!))
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
    var finish = false

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateExploreEvents), name: Notification.Name("eventsModified"), object: nil)
    }
    
    @objc func updateExploreEvents() {
        categories = {
            guard let events = PresenterManager.homePresenter?.allEvents else { return [:] }
            return Dictionary(grouping: events, by: {$0.tag})
        }()
        finish = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

