// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import LabelledGrid
import Keychain
import SwiftUI
import SwiftUIExtensions

public struct PreferencesView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var model: Model

    @State var settings = Settings()
    @State var owner: String = ""
    @State var token: String = ""
    @State var oldestNewest: Bool = false
    
    public init() {
    }
    
    public var body: some View {
        SheetView("ActionStatus Preferences", shortTitle: "Preferences", cancelAction: handleCancel, doneAction: handleSave) {
            PreferencesForm(
                settings: $settings,
                githubToken: $token,
                defaultOwner: $owner,
                oldestNewest: $oldestNewest)
                .environmentObject(context.formStyle)
        }
        .onAppear(perform: handleAppear)
    }

    func handleCancel() {
        presentation.wrappedValue.dismiss()
    }

    
    func handleAppear() {
        Application.shared.pauseRefresh()
        settings = context.settings
        owner = model.defaultOwner
        token = settings.readToken()
    }
    
    func handleSave() {
        model.defaultOwner = owner
        let authenticationChanged = settings.authenticationChanged(from: context.settings)
        context.settings = settings
        context.settings.writeToken(token)
        
        if authenticationChanged {
            Application.shared.resetRefresh()
        }

        Application.shared.resumeRefresh()
        presentation.wrappedValue.dismiss()
    }

}

public struct PreferencesForm: View {
    @Binding var settings: Settings
    @Binding var githubToken: String
    @Binding var defaultOwner: String
    @Binding var oldestNewest: Bool

    @EnvironmentObject var context: ViewContext

    enum PreferenceTabs: Int {
        case connection
        case display
        case other
        case debug
    }
    
    public var body: some View {
        TabView {
            ConnectionPrefsView(settings: $settings, token: $githubToken)
                .tag(PreferenceTabs.connection)
                .tabItem {
                    Label("Connection", systemImage: "network")
                }
            
            DisplayPrefsView(settings: $settings)
                .tag(PreferenceTabs.display)
                .tabItem {
                    Label("Display", systemImage: "display")
                }

            OtherPrefsView(owner: $defaultOwner, oldestNewest: $oldestNewest)
                .tag(PreferenceTabs.display)
                .tabItem {
                    Label("Other", systemImage: "slider.horizontal.3")
                }

            #if DEBUG
            DebugPrefsView(settings: $settings)
                .tag(PreferenceTabs.display)
                .tabItem {
                    Label("Debug", systemImage: "ant")
                }
            #endif

        }
        .padding()
    }
}

//        return Form {
//            FormSection(
//                header: { Text("Connection") },
//                footer: {
//                    HStack {
//                        Spacer()
//                        VStack(alignment: .trailing) {
//                            if settings.githubAuthentication {
//                                Text("With authentication, checking works for private repos and shows queued and running jobs. The token requires the following permissions:\n  notifications, read:org, read:user, repo, workflow.")
//                                HStack {
//                                    Text("More info... ")
//                                    LinkButton(url: URL(string: "https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token#creating-a-token")!)
//                                }
//                            } else {
//                                Text("Without authentication, checking works for public repos only.")
//                            }
//                        }
//                    }
//                }
//            ) {
//
//                ConnectionPrefsView(settings: $settings, token: $githubToken)
//            }
//
//            FormSection(
//                header: "Creation",
//                footer: "Defaults to use for new repos."
//            ) {
//                FormFieldRow(label: "Default Owner", variable: $defaultOwner, style: DefaultFormFieldStyle(contentType: .organizationName))
//            }
//
//            FormSection(
//                header: "Workflows",
//                footer: "Settings to use when generating workflow files."
//            ) {
//                FormToggleRow(label: "Test Lowest And Highest Only", variable: $oldestNewest)
//            }
//
//        }
//        .bestFormPickerStyle()
//    }

struct ConnectionPrefsView: View {
    @Binding var settings: Settings
    @Binding var token: String

    var body: some View {
        LabelledStack {
            LabelledToggle("Github", icon: "lock.circle", prompt: "Use github authentication", value: $settings.githubAuthentication)
            
            if settings.githubAuthentication {
                LabelledField("User", icon: "person", placeholder: "user", text: $settings.githubUser)
                LabelledField("Server", icon: "network", placeholder: "host", text: $settings.githubServer)
                LabelledField("Token", icon: "tag", placeholder: "token", text: $token)
            }

            LabelledPicker("Refresh Rate", icon: "lock.circle", value: $settings.refreshRate, values: RefreshRate.allCases)

            Spacer()
        }

    }
}


struct DisplayPrefsView: View {
    @Binding var settings: Settings

    var body: some View {
        LabelledStack {
            LabelledPicker("Item Size", icon: "arrow.up.and.down.circle", value: $settings.displaySize)
            LabelledPicker("Sort By", icon: "line.horizontal.3.decrease.circle", value: $settings.sortMode)
            #if targetEnvironment(macCatalyst)
            LabelledToggle("Show In Menubar", icon: "arrow.triangle.2.circlepath.circle", prompt: "Show menu", value: $settings.showInMenu)
            LabelledToggle("Show In Dock", icon: "arrow.triangle.2.circlepath.circle", prompt: "Show icon in dock", value: $settings.showInDock)
            #endif
            
            Spacer()
        }

    }
}

struct OtherPrefsView: View {
    @Binding var owner: String
    @Binding var oldestNewest: Bool
    
    var body: some View {
        LabelledStack {
            LabelledField("Default Owner", icon: "arrow.up.and.down.circle", placeholder: "github user or org", text: $owner)
            LabelledToggle("Workflows", icon: "arrow.triangle.2.circlepath.circle", prompt: "Test lowest & highest Swift", value: $oldestNewest)

            Spacer()
        }

    }
}

struct DebugPrefsView: View {
    @Binding var settings: Settings

    var body: some View {
        LabelledStack {
            LabelledToggle("Refresh", icon: "arrow.triangle.2.circlepath.circle", prompt: "Use test refresh controller", value: $settings.testRefresh)
            
            Spacer()
        }

    }
}


