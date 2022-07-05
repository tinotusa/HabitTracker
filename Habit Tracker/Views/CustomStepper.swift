//
//  CustomStepper.swift
//  Habit Tracker
//
//  Created by Tino on 27/6/2022.
//

import Combine
import SwiftUI

/// An editable stepper.
struct CustomStepper: View {
    /// The current value of the stepper.
    @Binding var value: Int {
        didSet {
            textValue = "\(value)"
        }
    }
    /// The minimum value of the stepper.
    let minValue: Int
    /// The maximum value of the stepper.
    let maxValue: Int
    /// The string representation for the value of the stepper.
    @State private var textValue: String
    
    init(value: Binding<Int>, minValue: Int, maxValue: Int) {
        _value = value
        _textValue = State<String>(wrappedValue: "\(value)")
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    var body: some View {
        HStack {
            StepperButton(systemName: "plus") {
                value = min(value + 1, maxValue)
            }
            
            TextField("", text: $textValue)
                .frame(width: 60)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .whiteBoxTextFieldStyle()
                .onSubmit {
                    updateValue()
                }
                .onReceive(Just(textValue)) { newValue in
                    filterTextValue(newValue)
                }
                .onChange(of: textValue) { _ in
                    updateValue()
                }
            
            StepperButton(systemName: "minus") {
                value = max(value - 1, minValue)
            }
        }
        .title2Style()
        .foregroundColor(.textColour)
    }
}

// MARK: - Functions
private extension CustomStepper {
    /// Updates the value for the stepper
    ///
    /// This function updates both the int binding and the string representation
    /// of the stepper.
    func updateValue() {
        let value = Int(textValue) ?? 0
        if value < minValue { self.value = minValue }
        else if value > maxValue { self.value = maxValue }
        else { self.value = value }
        textValue = "\(self.value)"
    }
    
    /// Filters the string input for the stepper.
    ///
    /// - Parameter value: The string value of the text field.
    func filterTextValue(_ value: String) {
        let filteredValue = value.filter { "0123456789".contains($0) }
        if filteredValue != value {
            textValue = filteredValue
        }
    }
}

// MARK: - Stepper Button
/// The button of the `CustomStepper`
fileprivate struct StepperButton: View {
    /// The sf symbol name for the buttons icon.
    let systemName: String
    /// The function the button must perform when pressed.
    let action: (() -> Void)?
    /// The size for the button.
    private let buttonSize = 50.0
    
    init(systemName: String, action: (() -> Void)? = nil) {
        self.systemName = systemName
        self.action = action
    }
    
    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: systemName)
                .padding()
                .frame(width: buttonSize, height: buttonSize)
                .background(Color.primaryColour)
                .cornerRadius(Constants.cornerRadius)
        }
    }
}

struct CustomStepper_Previews: PreviewProvider {
    static var previews: some View {
        CustomStepper(
            value: .constant(2),
            minValue: 0,
            maxValue: 20
        )
        .backgroundView()
    }
}
