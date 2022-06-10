//
//  PasswordResetView.swift
//  Habit Tracker
//
//  Created by Tino on 3/5/2022.
//

import SwiftUI

struct PasswordResetView: View {
    @StateObject var viewModel = PasswordResetViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Color("backgroundColour")
                    .ignoresSafeArea()
                
                closeButton
                
                VStack(spacing: 24) {
                    Text("Reset password")
                        .bodyStyle()
                    
                    TextField("Email", text: $viewModel.email, prompt: Text(viewModel.emailPlaceholder))
                        .inputField(imageName: "envelope.fill", contentType: .emailAddress)
                    
                    sendResetButton(proxy: proxy)
                }
                .padding()
                .frame(width: proxy.size.width)
                .frame(minHeight: proxy.size.height)
            }
        }
        .alert(
            viewModel.errorDetails?.name ?? "Error",
            isPresented: $viewModel.didError,
            presenting: viewModel.errorDetails
        ) { detail in
            // Default close button
        } message: { details in
            Text(details.message)
        }
    }
}

extension PasswordResetView {
    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "xmark")
                Text("Close")
            }
        }
        .bodyStyle()
        .padding()
        .zIndex(1)
    }
    
    func sendResetButton(proxy: GeometryProxy) -> some View {
        Button("Send reset email") {
            viewModel.sendResetEmail()
        }
        .disabled(!viewModel.allFieldsFilled)
        .buttonStyle(LongButtonStyle(proxy: proxy))
    }
    
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
