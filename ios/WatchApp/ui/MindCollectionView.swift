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
                    NavigationLink(
                        destination: {
                            NavigationLazyView(
                                MindDetailsView(
                                    viewModel:
                                        MindDetailsViewModel(
                                            mind: mind.wrappedValue,
                                            service: viewModel.service
                                        ),
                                        onDelete: { id in
                                            viewModel.minds.removeAll(where: { $0.uuid == id })
                                        }
                                )
                            )
                        },
                        label: {
                            EmojiView(mind.wrappedValue.emoji.description)
                        }
                    )
                        .buttonStyle(DefaultButtonStyle())
                }
                NavigationLink(
                    destination: {
                        NavigationLazyView(
                            MindCreatorView(
                                viewModel:
                                    MindCreatorViewModel(
                                        service: viewModel.service,
                                        onCreate: { mind in
                                            viewModel.minds.append(mind)
                                        }
                                    )
                            )
                        )
                    },
                    label: {
                        Text("+")
                            .font(.system(size: 30))
                            .frame(
                                width: .infinity,
                                height: .infinity
                            )
                        }
                )
            }
                .buttonStyle(DefaultButtonStyle())
                .padding()
        }
    }
}
