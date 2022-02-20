//
//  ContentView.swift
//  Bluetooth
//
//  Created by bnulo on 2/20/22.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject var delegateHandler = DelegateHandler.shared
    var body: some View {
        ScrollView {
            VStack {
//                Text(delegateHandler.statusText)
                ForEach(delegateHandler.statusList, id: \.self) { status in
                    Text(status)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .padding()
        }
    }
}
