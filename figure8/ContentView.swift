//
//  ContentView.swift
//  figure8
//
//  Created by Nathan Stankevicius on 9/6/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var currentDate = Date()
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    @ObservedObject var model = Model.shared
    @State var match = false
    
    @State var previousMag:CGFloat = 1
    @State var magnifyBy = CGFloat(1.0)
        var magnification: some Gesture {
            MagnificationGesture()
                .onChanged { gesture in
                    magnifyBy = min(max(0.1, gesture * previousMag), 5)
                }
                .onEnded { _ in
                    previousMag = magnifyBy
                }
        }
    


    
    var body: some View {
        
        let factor = 0.0
                
        ZStack(alignment: .bottom) {
            
            DrawingView(points: model.positions, magnification: Double(magnifyBy))
                .gesture(magnification)
            
            HStack(alignment: .top) {
                Slider(value: $model.speedUpFactor, in: 1.0...5.0) {
                    Text("x \(Int(model.speedUpFactor))")
                }.frame(width:300).padding()
                Spacer()
                VStack(alignment: .trailing, spacing: 20) {
                    
                    Button(action: {
                        model.clearPositions()
                    }, label: {
                        Text("Clear")
                    })
                    Button(action: {
                        model.resetPositions()
                        model.bank = .zero
                        model.windSpeed = .zero
                        model.windDirection = .zero
                        model.heading = Angle(value: 90, unit: .degrees)
                        match = false
                    }, label: {
                        Text("Reset")
                    })
                    Button(action: {
                        model.restorePosition()
                    }, label: {
                        Text("Snap-To")
                    })
                    
                    Spacer()
                }.padding()
                .buttonStyle(PlainButtonStyle())
                
            }.font(.largeTitle)
            HStack(alignment: .bottom) {
                ZStack {
                    WindSpeedSlider(speed: $model.windSpeed)
                    WindSlider(angle: $model.windDirection) .onReceive(timer) { input in
                            currentDate = input
                    }
                }
                Spacer()
                VStack {
                    Text("Ideal Bank: \((atan((pow(model.groundSpeed.converted(to:.knots).value,2))/(57795.4349028078))*180/Double.pi).angleOfBankDescription2)")
                    Text("Ground Speed: \(Int(model.groundSpeed.converted(to: .knots).value))kt")
                }
                .font(.system(size: 50, weight: .bold))
                Spacer()
                VStack {
                    Toggle(isOn: $match, label: {
                        Text(" Auto Bank").font(.largeTitle)
                    })
                    AngleOfBankSlider(bank: $model.bank)
                }
            }.padding()
        }.onReceive(timer, perform: { _ in
            let bank = min( atan((pow(model.groundSpeed.converted(to:.knots).value,2.0))/(57795.4349028078))*180.0/Double.pi + factor, 80.0)

            if match {
                model.bank = Angle(value: bank, unit: .degrees)
            }
            model.updatePosition()
        })
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/999.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/700.0/*@END_MENU_TOKEN@*/))
    }
}
