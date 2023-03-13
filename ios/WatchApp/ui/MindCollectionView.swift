import Foundation
import SwiftUI

struct MindCollectionView: View {
    
    @ObservedObject
    var viewModel: MainViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
            ) {
                ForEach($viewModel.minds, id: \.uuid) { mind in
                    MindRow(mind: mind.wrappedValue)
                }
                Button(action: {}) {
                    NavigationLink(
                        destination: MindCreatorView(
                            viewModel: MindCreatorViewModel(service: viewModel.service)),
                            label: { Text("+") }
                    )
                }
            }
            .padding()
        }
    }
}
