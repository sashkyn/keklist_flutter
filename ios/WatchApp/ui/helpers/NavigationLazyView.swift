import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    
    // TODO: Почитать про @autoclosure
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
