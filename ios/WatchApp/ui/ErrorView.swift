import SwiftUI

struct ErrorView: View {
    
    let retryAction: (() -> Void)?
    
    @ViewBuilder
    let errorLabel: () -> Text
    
    var body: some View {
        ScrollView {
            Spacer()
            errorLabel()
            if let retryAction {
                Spacer()
                Button(action: { retryAction() }) {
                    Text("Retry")
                }
            }
            Spacer()
        }
            .navigationTitle("Error")
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            retryAction: { print("retry") }
        ) {
           Text("Phone and Watch haven't paired yet")
        }
    }
}
#endif
