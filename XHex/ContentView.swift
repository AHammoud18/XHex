//
//  ContentView.swift
//  XHex
//
//  Created by Ali Hammoud on 3/28/24.
//

import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    
    @StateObject private var hexDump = HexDump.handler
    
    @State private var hexTester = XHexTest.tester
    
    @State private var fileLoaded: Bool = false
    @State private var isDebug: Bool = false
    @State private var isHovering: Bool = false
    @State private var showSide: NavigationSplitViewVisibility = .automatic
    
    @State private var firstAddress: String = ""
    @State private var lastAddress: String = ""
    
    var body: some View {
        GeometryReader { geo in
            NavigationSplitView(
                columnVisibility: $showSide,
                sidebar: { // Side Bar View
                    SideBar()
                        .onAppear {
                            
                        }
                },
                content: { // Main Window View
                    MainContent(geo: geo)
                },
                detail: { // Details Bar View
                    DetailsBar(geo: geo)
                }
            ).overlay{Button{
                print("geo.size: w-\(geo.size.width) : h-\(geo.size.height)")
            }label: {
                Text("Check Size")
                    .foregroundStyle(.white)
            }}
            //.foregroundStyle(.main)
            
            // Root View Modifiers
            .navigationSplitViewColumnWidth(min: 100, ideal: 120, max: 200)
            .navigationTitle("XHex")
            .navigationSplitViewStyle(.automatic)
        }.frame(minWidth: 800, minHeight: 600)
    }
    
    // #MARK: Side Bar
    private func SideBar() -> some View {
        return List {
            Text("ee")
        }
        
        .toolbar {
            ToolbarItem {
                Button(action: selectFile) {
                    Label("Select File", systemImage: "plus")
                }
            }
        }
        .toolbarTitleMenu {
            Text("hi")
        }
    }
    
    // #MARK: Main Window
    private func MainContent(geo: GeometryProxy) -> some View {
        // body of window
        return ZStack{
            if !fileLoaded {
                VStack {
                    Text("Select an item")
                        .foregroundStyle(.white)
                    Text(":3")
                        .foregroundStyle(.white)
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .overlay {
                        ScrollViewReader(content: { proxy in
                            ScrollView(.vertical) {
                                if isDebug {
                                    addressView(hexTester.mockData, geo)
                                } else {
                                    addressView(hexDump.dumpResults, geo)
                                }
                            }
                        })
                    }
                    .foregroundStyle(.red)
            }
        }
        // Main View Modifiers
        //.frame( minWidth: geo.frame(in: .global).width, minHeight: geo.frame(in: .global).height)
        .scaledToFill()
    }
    
    
    // #MARK: Detail View
    private func DetailsBar(geo: GeometryProxy) -> some View {
        return ZStack {
            VStack {
                // Details View
            }
        }
    }
    
    
    private func addressView(_ data: [String:[String]], _ geo: GeometryProxy) -> some View {

        return VStack {
            ForEach( hexDump.addresses, id: \.self ) { value in
                HStack(spacing: 20) {
                    Button {
                        print("Address: \(value)\nBytes: \(data[value]![0])\nAscii: \(data[value]![1])\n")
                    } label : {
                        Text(value)
                            .textSelection(.disabled)
                            .textFieldStyle(.roundedBorder)
                            .textCase(.uppercase)
                            .foregroundStyle(.white)
                            .font(.system(.body, design: .monospaced))
                    }
                    .id(value)
                    .padding(.leading)
                    .shadow(color: Color.purple, radius: isHovering ? 4 : 0)
                    .buttonStyle(PlainButtonStyle())
                    .onHover(perform: { hovering in
                        isHovering = hovering
                    })
                    
                    
                    HStack (spacing: 20) {
                        Text(data[value]![0])
                            .textSelection(.enabled)
                            .textCase(.uppercase)
                            .foregroundStyle(.white)
                            .font(.system(.body, design: .monospaced))
                        Text(data[value]![1])
                            .textSelection(.enabled)
                            .foregroundStyle(.white)
                            .font(.system(.body, design: .monospaced))
                            
                    }
                }
                //.background(Color.red)
                .frame(minWidth: geo.size.width, alignment: .leading)
            }
        }
    }

    private func selectFile() {
        let openBroswer = NSOpenPanel()
        openBroswer.canChooseFiles = true
        openBroswer.showsHiddenFiles = true
        openBroswer.allowsMultipleSelection = false
        openBroswer.canChooseDirectories = false
        openBroswer.begin { (result) in
            switch result {
            case .OK:
                fileLoaded = false
                if let file = openBroswer.url?.relativePath {
                    hexDump.runDump(file: [file])
                    fileLoaded = true
                }
            case .cancel:
                openBroswer.close()
                return
            default:
                return
            }
        }
    }
}

extension NavigationSplitView {
    
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
