// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components
import QRScanner
import Localization
import NameResolver
import struct Keystore.Mnemonic

struct ImportWalletScene: View {
    
    enum Field: Int, Hashable {
        case name, input
    }
    @State private var name: String = ""
    @State private var wordsSuggestion: [String] = []

    @State private var importType: WalletImportType = .phrase
    @State private var input: String = ""

    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingScanner = false
    @FocusState private var focusedField: Field?
    @State var nameResolveState: NameRecordState = .none
    
    @StateObject var model: ImportWalletViewModel

    init(model: ImportWalletViewModel) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    FloatTextField(Localized.Wallet.name, text: $name, allowClean: focusedField == .name)
                        .focused($focusedField, equals: .name)
                }
                Section {
                    VStack {
                        if model.showImportTypes {
                            Picker("", selection: $importType) {
                                ForEach(model.importTypes) { type in
                                    Text(type.title).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        HStack {
                            TextField(importType.description, text: $input, axis: .vertical)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .lineLimit(8)
                                .keyboardType(.asciiCapable)
                                .frame(minHeight: 80, alignment: .top)
                                .focused($focusedField, equals: .input)
                                .toolbar {
                                    if importType.showToolbar {
                                        ToolbarItem(placement: .keyboard) {
                                            WordSuggestionView(words: wordsSuggestion, selectWord: selectWord)
                                        }
                                    }
                                }
                                .padding(.top, .small + .tiny)
                            
                                if let chain = model.chain, importType == .address {
                                    NameRecordView(
                                        model: NameRecordViewModel(chain: chain),
                                        state: $nameResolveState,
                                        address: $input
                                    )
                            }
                        }
                        HStack(alignment: .center, spacing: 16) {
                            ListButton(
                                title: Localized.Common.paste,
                                image: Images.System.paste,
                                action: paste
                            )
                            if model.type != .multicoin {
                                ListButton(
                                    title: Localized.Wallet.scan,
                                    image: Images.System.qrCode,
                                    action: scanQR
                                )
                            }
                        }
                    }
                    .listRowBackground(Colors.white)
                } footer: {
                    if let text = model.footerText(type: importType) {
                        Text(text)
                    } else {
                        EmptyView()
                    }
                }
            }
            .listSectionSpacing(.compact)

            Spacer()
            StateButton(
                text: Localized.Wallet.Import.action,
                type: .primary(model.buttonState),
                action: onImportWallet
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.validation("")), message: Text($0))
        }
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
        }
        .onChange(of: input) { oldValue, newValue in
            wordsSuggestion = model.wordSuggestionCalculate(value: newValue)
        }
        .onChange(of: importType) { (_, _) in
            input = ""
        }
        .navigationBarTitle(model.title)
        .taskOnce {
            name = model.name
            importType = model.importTypes.first!
            focusedField = .input
        }
    }

    func selectWord(word: String) {
        input = model.selectWordCalculate(input: input, word: word)
    }
    
    func onHandleScan(_ result: String) {
        input = result
    }

    func validateForm(type: WalletImportType, address: String, words: [String]) throws  -> Bool {
        guard !name.isEmpty else {
            throw WalletImportError.emptyName
        }
        switch type {
        case .phrase:
            for word in words {
                if !Mnemonic.isValidWord(word) {
                    throw WalletImportError.invalidSecretPhraseWord(word: word)
                }
            }
            guard Mnemonic.isValidWords(words) else {
                throw WalletImportError.invalidSecretPhrase
            }
        case .privateKey:
            return !words.joined().isEmpty
        case .address:
            guard model.chain!.isValidAddress(address) else {
                throw WalletImportError.invalidAddress
            }
        }
        return true
    }
    
    func paste() {
        guard let string = UIPasteboard.general.string else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        input = string.trim()
    }
    
    func scanQR() {
        isPresentingScanner = true
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Actions

extension ImportWalletScene {
    func onImportWallet() {
        model.buttonState = .loading(showProgress: true)

        Task {
            try await Task.sleep(for: .milliseconds(50))
            do {
                try await MainActor.run {
                    try importWallet()
                }
            } catch {
                await MainActor.run {
                    isPresentingErrorMessage = error.localizedDescription
                    model.buttonState = .normal
                }
            }
        }
    }

    func importWallet() throws {
        let recipient: RecipientImport = {
            if let result = nameResolveState.result {
                return RecipientImport(name: result.name, address: result.address)
            }
            return RecipientImport(name: name, address: input)
        }()
        switch importType {
        case .phrase:
            let words = input.split(separator: " ").map{String($0)}
            guard try validateForm(type: importType, address: recipient.address, words: words) else {
                return
            }
            switch model.type {
            case .multicoin:
                try model.importWallet(
                    name: recipient.name,
                    keystoreType: .phrase(words: words, chains: AssetConfiguration.allChains)
                )
            case .chain(let chain):
                try model.importWallet(
                    name: recipient.name,
                    keystoreType: .single(words: words, chain: chain)
                )
            }
        case .privateKey:
            guard try validateForm(type: importType, address: recipient.address, words: [input]) else {
                return
            }
            try model.importWallet(name: recipient.name, keystoreType: .privateKey(text: input, chain: model.chain!))
        case .address:
            guard try validateForm(type: importType, address: recipient.address, words: []) else {
                return
            }
            let chain = model.chain!
            let address = chain.checksumAddress(recipient.address)
            
            try model.importWallet(name: recipient.name, keystoreType: .address(chain: chain, address: address))
        }
    }
}
