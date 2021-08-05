//
//  WindSpeedSlider.swift
//  figure8
//
//  Created by Nathan Stankevicius on 9/6/21.
//

import SwiftUI

struct WindSpeedSlider : View {
    
    @State var size: CGFloat = 280.0
    private let sliderFactor = 1.0
    @Binding var speed: Speed
    var angle: Double {
        speed.converted(to: .knots).value * sliderFactor
    }
    
    var sliderWidth: CGFloat = 30
    
    var body: some View{
        ZStack{
            
            Circle()
                .stroke(Color.gray,style: StrokeStyle(lineWidth: sliderWidth, lineCap: .round, lineJoin: .round))
                .frame(width:size, height: size)
            
            // progress....
            
                    Circle()
                        .trim(from: 0, to: CGFloat(angle/360))
                        .stroke(Color.green,style: StrokeStyle(lineWidth: sliderWidth, lineCap: .butt))
                        .frame(width: size, height: size)
                        .rotationEffect(.init(degrees: -90))
            
//             Inner Finish Curve...
            
                    Circle()
                        .fill(Color.gray)
                        .frame(width: sliderWidth, height: sliderWidth)
//                        .offset(x:90)
                        .offset(x: size / 2)
                        .rotationEffect(.init(degrees: -90))
            
            // Drag Circle...
            
            Circle()
                .fill(Color.white)
                .frame(width: sliderWidth, height: sliderWidth)
                .offset(x: size / 2)
                .rotationEffect(.init(degrees: angle))
            // adding gesture...
                .gesture(DragGesture().onChanged(onDrag(value:)))
                .rotationEffect(.init(degrees: -90))
            
            VStack {
                Text("\(Int(speed.converted(to: .knots).value)) kt").font(Font.system(.largeTitle, design: .monospaced))

            }.font(.largeTitle)
            
        }
            .frame(width:size+sliderWidth, height: size+sliderWidth)
    }
    
    func onDrag(value: DragGesture.Value){
        
        // calculating radians...
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        let radians = atan2(vector.dy - sliderWidth/2, vector.dx - sliderWidth/2)
        
        // converting to angle...
        
        var angle = radians * 180 / .pi
        
        // simple technique for 0 to 360...
        
        if angle < 0{angle = 360 + angle}
        
        self.speed = Speed(value: Double(angle) / sliderFactor, unit: .knots)
    }
}

struct WindSpeedSlider_Previews: PreviewProvider {
    static var previews: some View {
        WindSpeedSlider(speed: Binding.constant(Speed(value: 20, unit: .knots)))
    }
}
