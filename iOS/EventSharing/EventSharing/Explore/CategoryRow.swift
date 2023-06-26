import SwiftUI

struct CategoryRow: View {
    var categoryName: String
    var events: [Event]
    
    var body: some View {
        ZStack{

            VStack(alignment: .leading) {

                Text(categoryName)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 15)
                    .padding(.top, 5)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(events,  id: \.self) {
                            event in
                            EventElement(title: event.title, location: event.address, eventImage: Image(uiImage: UIImage(data: event.image!) ?? UIImage()))
                                .onTapGesture {
                                    PresenterManager.mainPresenter?.presentInfoEvent((PresenterManager.homePresenter?.homeViewController)!, event: event, nil)
                                }
                        }
                    }
                }
                .frame(height: 185)
            }

        }
    }
}

//struct CategoryRow_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryRow(categoryName: "Motorsport")
//    }
//}
