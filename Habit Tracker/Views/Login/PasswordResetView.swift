//
//  PasswordResetView.swift
//  Habit Tracker
//
//  Created by Tino on 3/5/2022.
//

import SwiftUI

struct PasswordResetView: View {
    @StateObject private var viewModel = PasswordResetViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: Constants.vstackSpacing) {
            closeButton
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            
            Text("Reset password")
                .title2Style()
            
            TextField("Email", text: $viewModel.email, prompt: Text(viewModel.emailPlaceholder))
                .inputField(imageName: "envelope.fill", contentType: .emailAddress)
            
            sendResetButton
            
            Spacer()
        }
        .padding()
        .backgroundView()
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

private extension PasswordResetView {
    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "xmark")
                Text("Close")
            }
        }
        .title2Style()
        .padding()
        .zIndex(1)
    }
    
    var sendResetButton: some View {
        LongButton(text: "Send reset email", isDisabled: !viewModel.allFieldsFilled) {
            viewModel.sendResetEmail()
        }
    }
    
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
