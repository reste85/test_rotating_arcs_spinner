//
//  RotatingArcsView.swift
//  TestDrawRotatingArcs
//
//  Created by Matteo Restelli on 20/05/16.
//

import UIKit
import CoreGraphics

class RotatingArcsView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // Start angle of the strokes
    // radians = degrees / (180.0 / M_PI)
    struct RotatingArcsViewStartAngles{
        static let Internal : CGFloat! = CGFloat(180.0 / (180.0 / M_PI))
        static let External : CGFloat! = CGFloat(90.0 / (180.0 / M_PI))
    }
    
    var angleExternalArc : CGFloat!
    var angleInternalArc : CGFloat!
    var revolutionsPerSecond : CGFloat!
    var displayLink : CADisplayLink!
    var startTime : CFTimeInterval!
    var currentStrokeColor : CGColor!
    var isRotating : Bool!
    var stopRequested : Bool!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        resetArcsStatus()
        self.isRotating = false;
        self.stopRequested = false;
        self.currentStrokeColor = UIColor(red: 0.0, green: 142/255.0, blue: 111/255.0, alpha: 1).CGColor
    }
    
    func resetArcsStatus() {
        self.angleExternalArc = RotatingArcsViewStartAngles.External
        self.angleInternalArc = RotatingArcsViewStartAngles.Internal
        self.revolutionsPerSecond = 0.50 // i.e. go around once per every 2 seconds
    }
    
    func startDisplayLink() {
        if(self.isRotating == false) {
            self.displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
            self.startTime = CACurrentMediaTime()
            self.displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            self.isRotating = true
        }
    }
    
    func delayedStopArcRotation() {
        if(self.isRotating == true) {
            self.stopRequested = true;
        }
    }
    
    func stopArcRotation() {
        stopRotation()
    }
    
    private func stopRotation() {
        if(self.isRotating == true) {
            dispatch_async(dispatch_get_main_queue(),{
                self.isRotating = false
                self.resetArcsStatus()
                self.setNeedsDisplay()
                self.displayLink.invalidate()
                self.displayLink = nil
            })
        }
    }
    
    func handleDisplayLink(displayLink : CADisplayLink) {
        let elapsed : CFTimeInterval  = CACurrentMediaTime() - self.startTime;
        var revolutions = Double()
        /*if(self.stopRequested == true && self.revolutionsPerSecond <= CGFloat(0.60)) {
            self.revolutionsPerSecond = self.revolutionsPerSecond + CGFloat(0.01)
            NSLog(String(self.revolutionsPerSecond))
        }*/
        let percent = modf((elapsed * (Double(self.revolutionsPerSecond))), &revolutions)
        self.angleExternalArc = RotatingArcsViewStartAngles.External + CGFloat((M_PI * 2.0 * percent))
        self.angleInternalArc = RotatingArcsViewStartAngles.Internal - CGFloat((M_PI * 2.0 * percent))
        NSLog(String(self.angleInternalArc * CGFloat(180.0 / M_PI)))
        self.performSelectorOnMainThread(#selector(self.setNeedsDisplay), withObject: nil, waitUntilDone: false)
    }
    
    override func drawRect(rect: CGRect) {
        let context : CGContextRef? = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, self.currentStrokeColor);
        CGContextSetLineWidth(context, 2);
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextAddArc(context,
                        self.frame.size.width/2, self.frame.size.height/2, //center
            min(self.frame.size.width, self.frame.size.height) / 2.0 - 2.0, //radius
            0.0 + self.angleExternalArc, 1.7 * CGFloat(M_PI) + self.angleExternalArc, //arc start/finish
            0);
        CGContextStrokePath(context);
        
        CGContextSetLineWidth(context, 2);
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextAddArc(context,
                        self.frame.size.width/2, self.frame.size.height/2, //center
            min(self.frame.size.width * 0.85, self.frame.size.height * 0.85) / 2.0 - 2.0, //radius
            0.0 + self.angleInternalArc, CGFloat(M_PI)/CGFloat(2.0) + self.angleInternalArc, //arc start/finish
            1);
        CGContextStrokePath(context);
        self.handleDelayedStop()
    }
    
    private func handleDelayedStop() {
        if(self.stopRequested == true) {
            let currentInternalAngleDegrees = Int(self.angleInternalArc * CGFloat(180.0 / M_PI))
            let startInternalAngleDegrees = Int(RotatingArcsViewStartAngles.Internal * CGFloat(180.0 / M_PI))
            
            if (abs(abs(currentInternalAngleDegrees) - startInternalAngleDegrees) <= 5) {
                self.stopRequested = false
                stopRotation()
            }
        }
    }

}
