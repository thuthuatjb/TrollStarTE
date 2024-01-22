/*
 * Copyright (c) 2023 Félix Poulin-Bélanger. All rights reserved.
 */

import SwiftUI

struct ContentView: View {
    @State private var kfd: UInt64 = 0
    @State private var puafPagesIndex = 7
    @State private var puafPages = 0
    @State private var puafMethod = 2
    @State private var kreadMethod = 1
    @State private var kwriteMethod = 1
    @State private var installationStatus = false
    @State private var kopenStatus = false

    private let puafPagesOptions = [16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 32768]
    private let puafMethodOptions = ["physpuppet", "smith", "landa"]
    private let kreadMethodOptions = ["kqueue_workloop_ctl", "sem_open"]
    private let kwriteMethodOptions = ["dup", "sem_open"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration")) {
                    Picker("puaf pages:", selection: $puafPagesIndex) {
                        ForEach(0 ..< puafPagesOptions.count, id: \.self) {
                            Text("\(self.puafPagesOptions[$0])")
                        }
                    }.disabled(kfd != 0)

                    Picker("puaf method:", selection: $puafMethod) {
                        ForEach(0 ..< puafMethodOptions.count, id: \.self) {
                            Text(self.puafMethodOptions[$0])
                        }
                    }.disabled(kfd != 0)

                    Picker("kread method:", selection: $kreadMethod) {
                        ForEach(0 ..< kreadMethodOptions.count, id: \.self) {
                            Text(self.kreadMethodOptions[$0])
                        }
                    }.disabled(kfd != 0)

                    Picker("kwrite method:", selection: $kwriteMethod) {
                        ForEach(0 ..< kwriteMethodOptions.count, id: \.self) {
                            Text(self.kwriteMethodOptions[$0])
                        }
                    }.disabled(kfd != 0)
                }

                Section(header: Text("Actions")) {
                    //HStack {
                        Button("Click here to start!") {
                            UIApplication.shared.alert(title: "Exploiting Kernel...", body: "well, waiting for kopen...", withButton: false)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                puafPages = puafPagesOptions[puafPagesIndex]
                                kfd = do_kopen(UInt64(puafPages), UInt64(puafMethod), UInt64(kreadMethod), UInt64(kwriteMethod))
                                do_fun()
                                
                                // Show kopen status and reset installationStatus
                                kopenStatus = true
                                installationStatus = false
                                UIApplication.shared.dismissAlert(animated: true)
                            }
                        }.disabled(kfd != 0)
                        //.buttonStyle(.bordered)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    //}
                }


                Section(header: Text("Utilities")) {
                    Button("Install TrollStore Helper to Tips") {
                        UIApplication.shared.alert(title: "Installing TrollHelper...", body: "imagine how the Tips app is useful in its own way...", withButton: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            processDirectories()
                            
                            // Show installation log messages and reset kopenStatus
                            installationStatus = true
                            kopenStatus = false
                        }
                    }.disabled(kfd == 0)

                    Button("Respring to Apply") {
                        do_kclose()
                        backboard_respring()
                    }.disabled(kfd == 0)
                }

                Section(header: Text("Status")) {
                    VStack {
                        if kopenStatus {
                            Text("kopen success!").foregroundColor(.green)
                            Text("Now press on \"Install Trollstore Helper to Tips\"")
                        }
                        if installationStatus {
                            Text("Please press \"Respring to Apply\".\n\nIf Tips still not TrollHelper, reinstall Tips from AppStore (do not open) then reboot and try again")
                        }
                        if !(installationStatus || kopenStatus) {
                            HStack(alignment: .center) {
                                VStack {
                                    Text("Made by Little34306 and straight-tamago")
                                        .font(.caption)
                                    Text("\nv" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String))
                                        .font(.caption)
                                }
                                //Spacer()
                            }
                        }
                    }
                    .foregroundColor(.yellow)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }

            }
            .navigationBarTitle(Text("TrollStore Installer Helper"), displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
