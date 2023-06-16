import SwiftUI

struct EventElement: View {
    var title: String
    var location: String
    var eventImage: Image

    var body: some View {
        HStack {
            ZStack {
                eventImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .background(Color.black)
                
                Color.black.opacity(0.5)
                    .frame(width: 200, height: 200)
                
                VStack {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(width: 200, height: 200)
            }
            .cornerRadius(20)
            .padding(.leading, 10)
        }

    }
}

//struct EventElement_Previews: PreviewProvider {
//    static var previews: some View {
////        let events = (PresenterManager.homePresenter?.events)!
////        EventElement(event: events[1])
//        EventElement(title: "MonzaGP", location: "Monza, Italia", eventImage: Image(uiImage: UIImage(named: "monza")!) )
//
//    }
//}
