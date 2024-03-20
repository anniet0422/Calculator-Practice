//
//  ContentView.swift
//  Calculator
//
//  Created by Annie Tran on 3/19/24.
//

import SwiftUI

//this extension is so I can use hex colors
extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        print(cleanHexCode)
        var rgb: UInt64 = 0
        
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}


struct ContentView: View {
    
    let grid = [["AC", "Del", "%", "/"],
                ["7", "8", "9", "X"],
                ["4", "5", "6", "-"],
                ["1", "2", "3", "+"],
                [".", "0", "", "="]
    ]
    
    let operators = ["/", "+", "X", "%"]
    
    @State var visableWorkings = ""
    @State var visableResults = ""
    @State var showAlert  = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Text(visableWorkings)
                    .padding()
                    .foregroundColor(Color.white)
                    .font(.system(size: 30, weight: .heavy))
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Spacer()
                Text(visableResults)
                    .padding()
                    .foregroundColor(Color.white)
                    .font(.system(size: 50, weight: .heavy))
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            //this will make it take all of the available space
            
            ForEach(grid, id: \.self){
                row in
                HStack{
                ForEach(row, id: \.self){
                    cell in
                    
                    Button(action: { buttonPressed(cell: cell)}, label: {
                        Text(cell)
                            .foregroundColor(buttonColor(cell))
                            .font(.system(size: 40, weight: .heavy))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    })
                }}
            }
        }
        .background(Color(hex: "FFBCD9").ignoresSafeArea())
        .alert(isPresented: $showAlert){
            Alert(title: Text("Invalid Input"),
                  message: Text(visableWorkings),
                  dismissButton: .default(Text("Okay"))
                  )
                  }
        
    }
    
    func buttonColor(_ cell: String) -> Color{
        
        if(cell == "AC" || cell == "Del"){
            return .red
        }
        
        if(cell == "-" || cell == "=" || operators.contains(cell)){
            return .orange
            
        }
        return .white
    }
    
    func buttonPressed(cell: String){
        
        switch cell {
        case "AC": 
            visableWorkings = ""
            visableResults = ""
        case "Del":
            visableWorkings = String(visableWorkings.dropLast())
        case "=":
            visableResults = calculateResults()
        case "-":
            addMinus()
        case "X", "/", "%", "+":
            addOperator(cell)
        default:
            visableWorkings += cell
        }
        
    }
    func addOperator(_ cell : String) {
                if !visableWorkings.isEmpty{
                    let last = String(visableWorkings.last!)
                    if operators.contains(last) || last == "-" {
                        visableWorkings.removeLast()
                    }
                    visableWorkings += cell
                }
            }
    func addMinus() {
                if visableWorkings.isEmpty || visableWorkings.last! != "-"{
                    visableWorkings += "-"
                }
            }
    
    func calculateResults() -> String {
        
        if(validInput()) {
        var workings = visableWorkings.replacingOccurrences(of: "%", with: "*0.01")
        workings = visableWorkings.replacingOccurrences(of: "X", with: "*")
        let expression = NSExpression(format: workings)
        let result = expression.expressionValue(with: nil, context: nil) as! Double
        return formatResult(val: result)
            }
        showAlert = true
        return ""
    }
    
    func validInput() -> Bool {
        if(visableWorkings.isEmpty){
            return false
        }
        let last = String(visableWorkings.last!)
        
        if(operators.contains(last) || last == "-"){
            if(last != "%" || visableWorkings.count == 1){
                return  false
            }
        }
        return true
    }
    
    func formatResult(val : Double) -> String {
        if(val.truncatingRemainder(dividingBy: 1) == 0){
            return String(format: "%.0f", val)
        }
        return String(format: "%.2f", val)
    }

}

#Preview {
    ContentView()
}
