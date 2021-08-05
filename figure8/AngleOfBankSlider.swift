//
//  AngleOfBankSlider.swift
//  figure8
//
//  Created by Nathan Stankevicius on 9/6/21.
//

import SwiftUI

struct AngleOfBankSlider : View {
    
    @State var size: CGFloat = 200.0
    @Binding var bank: Angle
    let slideFactor = 2.0
    
    var sliderWidth: CGFloat = 30
    
    var body: some View{
        ZStack{
            
            Circle()
                .stroke(Color.gray,style: StrokeStyle(lineWidth: sliderWidth, lineCap: .round, lineJoin: .round))
                .frame(width:size, height: size)
            
            // progress....
            
            Circle()
                .trim(from: bank.value >= 0 ? 0 : 1 + CGFloat(bank.degrees * slideFactor) / 360, to: bank.value >= 0 ? CGFloat(bank.degrees * slideFactor/360) : 1)
                        .stroke(Color.green,style: StrokeStyle(lineWidth: sliderWidth, lineCap: .butt))
                        .frame(width: size, height: size)
                        .rotationEffect(.init(degrees: -90))
            
            // Drag Circle...
            
            Circle()
                .fill(Color.white)
                .frame(width: sliderWidth, height: sliderWidth)
                .offset(x: size / 2)
                .rotationEffect(.init(degrees: bank.degrees * slideFactor))
            // adding gesture...
                .gesture(DragGesture(minimumDistance:0).onChanged(onDrag(value:)))
                .rotationEffect(.init(degrees: -90))
            
            VStack {
                Text("Bank").fontWeight(.bold)
                Text(bank.converted(to: .degrees).value.angleOfBankDescription).font(Font.system(.largeTitle, design: .monospaced))

            }.font(.largeTitle)
            
        }
            .frame(width:size+sliderWidth, height: size+sliderWidth)
    }
    
    func onDrag(value: DragGesture.Value) {
        
        // calculating radians...
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        let radians = Double(atan2(vector.dy - sliderWidth/2, vector.dx - sliderWidth/2))
        
        // converting to angle...
        
        var angle = Angle(value: radians, unit: .radians).degrees360minus
        
        angle = angle.cappedBetween(lhs: -60 * slideFactor, rhs: 60 * slideFactor)
        
        self.bank = Angle(value: Double(angle / 2), unit: .degrees)
    }
}

struct AngleOfBankSlider_Previews: PreviewProvider {
    static var previews: some View {
        AngleOfBankSlider(bank: Binding.constant(Angle(value: -45, unit: .degrees)))
    }
}


extension View {
  @ViewBuilder
  func `if`<TrueContent: View, FalseContent: View>(
    _ condition: Bool,
    if ifTransform: (Self) -> TrueContent,
    else elseTransform: (Self) -> FalseContent
  ) -> some View {
    if condition {
      ifTransform(self)
    } else {
      elseTransform(self)
    }
  }
}

extension Double {
    var angleOfBankDescription: String {
        let formatter = NumberFormatter()
        formatter.negativePrefix = "L "
        formatter.positivePrefix = "R "
        formatter.maximumFractionDigits = 0
        formatter.positiveSuffix = "˚"
        formatter.negativeSuffix = "˚"
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension Double {
    var angleOfBankDescription2: String {
        let formatter = NumberFormatter()
        formatter.negativePrefix = ""
        formatter.positivePrefix = ""
        formatter.maximumFractionDigits = 0
        formatter.positiveSuffix = "˚"
        formatter.negativeSuffix = "˚"
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension SignedNumeric where Self: Comparable {
    
    func cappedBetween(lhs:Self, rhs:Self) -> Self {
        let min = lhs < rhs ? lhs : rhs
        let max = min == lhs ? rhs : lhs
        switch self {
        case let x where x <= min:
            return min
        case let x where x > min && x < max:
            return x
        default:
            return max
        }
    }
}
