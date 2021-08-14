//
//  DrawingView.swift
//  figure8
//
//  Created by Nathan Stankevicius on 9/6/21.
//

import SwiftUI

struct DrawingView: View {
    var points:[Position]
    let scaleFactor = 0.25
    let model = Model.shared
    var magnification: Double
    
    @State private var offset = CGSize.zero
    @State private var previousOffset = CGSize.zero
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged { value in
                self.offset = CGSize(width: value.translation.width / CGFloat(magnification) + previousOffset.width, height: value.translation.height / CGFloat(magnification) + previousOffset.height)
            }
            .onEnded { _ in
                self.previousOffset = self.offset
            }
        
        ZStack {
            
            Path { path in
                path.addLines(points.map(\.point))
            }.strokedPath(StrokeStyle(lineWidth: 100)).foregroundColor(.accentColor)
            
            .scaleEffect(CGSize(width: scaleFactor, height: scaleFactor), anchor: .topLeading)
            
            Path { path in
                path.move(to: model._currentPosition().point)
                path.addLine(to: Position(radial: model.heading, range: Distance(value: 0.3, unit: .nauticalMiles), fromPosition: model._currentPosition()).point)
            }.strokedPath(StrokeStyle(lineWidth: 50)).foregroundColor(.white)
            .scaleEffect(CGSize(width: scaleFactor, height: scaleFactor), anchor: .topLeading)
            
            Circle().path(in: CGRect(x: 500, y: 100, width: 3124 * scaleFactor, height: 3124 * scaleFactor)).stroke(Color.green,style: StrokeStyle(lineWidth: 1, lineCap: .butt))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(offset)
        .scaleEffect(CGFloat(magnification))
        .background(Color.black)
        .gesture(dragGesture)
        .drawingGroup()

    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(points: [Position(x: Distance(value: 0, unit: .meters), y: .zero), Position(x: Distance(value: 1, unit: .nauticalMiles), y: .zero)], magnification: 1)
            .preferredColorScheme(.light)
    }
}
