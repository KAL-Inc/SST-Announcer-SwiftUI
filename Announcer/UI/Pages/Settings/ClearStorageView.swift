//
//  ClearStorageView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 12/1/23.
//

import SwiftUI

struct ClearStorageView: View {
    @State
    var excludePinnedPosts: Bool = true

    @Environment(\.presentationMode)
    var presentationMode

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Text("WARNING:\n")
                        .foregroundColor(.red)
                        .bold()
                    +
                    Text("""
If you delete all stored posts, you will not be able to access them offline.
You may also lose the ability to view some of your pinned posts.
""")
                    Spacer()
                }
                .multilineTextAlignment(.center)
            }

            Section {
                Toggle("Do not delete pinned posts", isOn: $excludePinnedPosts)
                Button("Delete Post Storage\(excludePinnedPosts ? "\n(Excluding Pinned Posts)" : "")",
                       role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Clear Storage")
    }
}

struct ClearStorageView_Previews: PreviewProvider {
    static var previews: some View {
        ClearStorageView()
    }
}