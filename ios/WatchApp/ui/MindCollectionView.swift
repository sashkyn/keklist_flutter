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
                    NavigationLink {
                        NavigationLazyView(
                            MindDetailsView(
                                viewModel: MindDetailsViewModel(
                                    mind: mind.wrappedValue,
                                    service: viewModel.service
                                )
                            )
                        )
                    } label: {
                        MindRow(mind: mind.wrappedValue)
                    }
                    .buttonStyle(DefaultButtonStyle())
                }
                Button(action: {}) {
                    NavigationLink {
                        NavigationLazyView(
                            MindCreatorView(
                                viewModel: MindCreatorViewModel(
                                    service: viewModel.service,
                                    onCreate: { mind in
                                        viewModel.minds.append(mind)
                                    }
                                )
                            )
                        )
                    }
                    label: { Text("+") }
                }
            }
            .padding()
        }
    }
}

private struct MindRow: View {
    let mind: Mind

    var body: some View {
        Text(mind.emoji.description)
            .font(.system(size: 30))
    }
}
