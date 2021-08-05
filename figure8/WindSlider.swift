//
//  WindSlider.swift
//  figure8
//
//  Created by Nathan Stankevicius on 9/6/21.
//

import Foundation
import SwiftUI

struct WindSlider : View {
    
    @State var size: CGFloat = 200.0
//    @State var progress : CGFloat = 0.5
    @Binding var angle: Angle
    
    var sliderWidth: CGFloat = 30
    
    var body: some View{
        ZStack{
            
            Circle()
                .stroke(Color(.gray),style: StrokeStyle(lineWidth: sliderWidth, lineCap: .round, lineJoin: .round))
                .frame(width:size, height: size)
            
            // progress....
            
//                    Circle()
//                        .trim(from: 0, to: progress)
//                        .stroke(Color.green,style: StrokeStyle(lineWidth: 55, lineCap: .butt))
//                        .frame(width: size, height: size)
//                        .rotationEffect(.init(degrees: -90))
            
            // Inner Finish Curve...
            
//                    Circle()
//                        .fill(Color(.red))
//                        .frame(width: 55, height: 55)
////                        .offset(x:90)
//                        .offset(x: size / 2)
//                        .rotationEffect(.init(degrees: -90))
            
            // Drag Circle...
            
            Circle()
                .fill(Color.white)
                .frame(width: sliderWidth, height: sliderWidth)
                .offset(x: size / 2)
                .rotationEffect(.init(degrees: angle.degrees))
            // adding gesture...
                .gesture(DragGesture().onChanged(onDrag(value:)))
                .rotationEffect(.init(degrees: -90))
            
            // sample $200
//                    Text("$" + String(format: "%.0f", progress * 200))
//                        .font(.largeTitle)
//                        .fontWeight(.heavy)
            
            ArrowView()
                .frame(width: size / 4, height: size / 1.5)
                .rotationEffect(.init(degrees: angle.degrees))
                .opacity(0.5)
        }
            .frame(width:size+sliderWidth, height: size+sliderWidth)
    }
    
    func onDrag(value: DragGesture.Value){
        
        // calculating radians...
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        // since atan2 will give from -180 to 180...
        // eliminating drag gesture size
        // size = 55 => Radius = 27.5...
        
        let radians = atan2(vector.dy - sliderWidth/2, vector.dx - sliderWidth/2)
        
        // converting to angle...
        
        var _angle = radians * 180 / .pi
        
        // simple technique for 0 to 360...
        
        // eg = 360 - 176 = 184...
        if _angle < 0{_angle = 360 + _angle}
        
//        withAnimation(Animation.linear(duration: 0.15)){
            
            // progress...
//            let progress = angle / 360
//            self.progress = progress
        self.angle = Angle(value: Double(_angle), unit: .degrees)
//        }
    }
}

struct WindSlider_Previews: PreviewProvider {
    static var previews: some View {
        WindSlider(angle: Binding.constant(Angle(value: 170, unit: .degrees)))
    }
}
