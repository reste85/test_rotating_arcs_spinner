//
//  ViewController.swift
//  TestDrawRotatingArcs
//
//  Created by Matteo Restelli on 20/05/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var rotatingArcsView: RotatingArcsView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButton(sender: AnyObject) {
        rotatingArcsView.startDisplayLink()
    }

    @IBAction func stopButton(sender: AnyObject) {
        rotatingArcsView.stopArcRotation()
    }

    @IBAction func delayedStopButton(sender: AnyObject) {
        rotatingArcsView.delayedStopArcRotation()
    }
}

