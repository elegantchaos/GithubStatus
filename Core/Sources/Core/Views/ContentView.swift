// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import BindingsExtensions
import SheetController
import SwiftUI
import SwiftUIExtensions

public struct ContentView: View {
    
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var sheetController: SheetController
    @Namespace() var defaultNamespace
    
    public init() {
    }
    
    public var body: some View {
        let name = Application.shared.info.name
        return SheetControllerHost {
            NavigationView {
                VStack(alignment: .center) {
                    if model.count == 0 {
                        NoReposView()
                    } else if viewState.settings.isEditing {
                        RepoListView(namespace: defaultNamespace)
                    } else {
                        RepoGridView(namespace: defaultNamespace)
                    }
                    
                    Spacer()
                    FooterView()
                }
                .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            if viewState.settings.isEditing {
                                AddButton()
                            }
                        }
                    
                    ToolbarItem(placement: .principal) {
                        Text(name)
                            .font(.title)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ToggleEditingButton()
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        }
        .onAppear(perform: onAppear)
    }
    
    func onAppear()  {
        #if !os(tvOS)
        UITableView.appearance().separatorStyle = .none
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

fileprivate extension View {
    #if os(tvOS) || targetEnvironment(macCatalyst)
    
    // MARK: tvOS/macOS Don't show nav bar
    
    func setupNavigation() -> some View {
        return
            navigationBarTitle("")
                .navigationBarHidden(true)
    }
    
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS
    
    func setupNavigation() -> some View {
        let name = Application.shared.info.name
        return
            navigationBarTitle(Text(name), displayMode: .inline)
                .navigationBarItems(
                    leading: AddButton(),
                    trailing: ToggleEditingButton()
                )
    }
    
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    
    #endif
}
