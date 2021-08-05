//
//  ArrowView.swift
//  figure8
//
//  Created by Nathan Stankevicius on 9/6/21.
//

import SwiftUI

struct ArrowView: Shape {
//    @State var rotation: Double
    
    func path(in rect: CGRect) -> Path {
                  let width = rect.width
                  let height = rect.height
        
        var path = Path()
                  
        path.addLines( [
            CGPoint(x: width * 0.4, y: height),
            CGPoint(x: width * 0.4, y: height * 0.3),
            CGPoint(x: width * 0.2, y: height * 0.35),
            CGPoint(x: width * 0.5, y: height * 0),
            CGPoint(x: width * 0.8, y: height * 0.35),
            CGPoint(x: width * 0.6, y: height * 0.3),
            CGPoint(x: width * 0.6, y: height),
            CGPoint(x: rect.midX, y: height * 0.9)
        ])
        path.closeSubpath()
        return path
    }
}

struct ArrowView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowView()
    }
}
