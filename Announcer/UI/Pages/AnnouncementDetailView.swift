//
//  AnnouncementDetailView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI
import RichText

struct AnnouncementDetailView: View {
    @Binding
    var post: Post

    @Binding
    var posts: [Post]

    @State
    var showEditCategoryView: Bool = false

    var body: some View {
        List {
            title

            categories
                .listRowSeparator(.hidden, edges: .top)

            TimeAndReminder(post: post)
                .font(.subheadline)
                .offset(y: -3)
                .listRowSeparator(.hidden, edges: .top)

            bodyText
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {

                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    post.pinned.toggle()
                } label: {
                    Image(systemName: post.pinned ? "pin.fill" : "pin")
                }
            }
        }
        .sheet(isPresented: $showEditCategoryView) {
            if #available(iOS 16.0, *) {
                addNewCategory
                    .presentationDetents(Set([.large, .medium]))
            } else {
                // Fallback on earlier versions
                addNewCategory
            }
        }
    }

    var title: some View {
        // title
        HStack {
            Text(post.title)
                .bold()
                .multilineTextAlignment(.leading)
        }
        .font(.title2)
        .padding(.bottom, -5)
    }

    var categories: some View {
        // categories
        HStack {
            CategoryScrollView(post: $post)
                .font(.subheadline)
            Button {
                // add category
                showEditCategoryView.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .opacity(0.6)
            }
        }
    }

    var links: some View {
        // if it has links
        VStack(alignment: .leading) {
            Text("Links")
                .bold()
            ForEach(["https://www.youtube.com", "https://www.google.com"], id: \.self) { url in
                Text(url)
                    .underline()
                    .foregroundColor(.accentColor)
            }
        }
    }

    var bodyText: some View {
        // body text
        // TODO: Make this compatable with html text
        VStack {
            RichText(html: post.content)
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                // open in safari
            } label: {
                Image(systemName: "arrow.up.forward.circle")
                    .opacity(0.6)
                    .offset(x: 6, y: 3)
            }
        }
        .padding(.top, 10)
    }

    var addNewCategory: some View {
        NavigationView {
            EditCategoriesView(post: $post,
                               posts: $posts,
                               showEditCategoryView: $showEditCategoryView)
        }
    }
}

struct AnnouncementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementDetailView(post: .constant(
                Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                     content: placeholderTextLong,
                     date: .now,
                     pinned: true,
                     read: false,
                     categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ],
                     userCategories: [
                        .init("placeholder")
                     ])), posts: .constant([]))
        }
    }
}