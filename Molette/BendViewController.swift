import AudioKit
import UIKit


class BendViewController: UIViewController, AKMIDIListener {
    
    //MARK: Properties
    @IBOutlet weak var wheel: UIView!
    @IBOutlet weak var index: UIView!
    
    var midi = AudioKit.midi
    
    var ccToSend: Int = 21
    var ccChanToSend: Int = 0
    
    var animationFrame = CADisplayLink(
            target: self,
            selector: #selector(onEnterFrame)
    )
    
    // INIT
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wheel.layer.borderWidth = 3
        wheel.layer.borderColor = UIColor.white.cgColor
        
        index.frame.size.width = wheel.frame.size.width
        index.frame.size.height = 4
        index.center.y = wheel.center.y
        index.center.x = wheel.center.x
        
        index.layer.backgroundColor = UIColor.white.cgColor
        
        midi.openOutput()
        
        self.animationFrame = CADisplayLink(
               target: self,
               selector: #selector(onEnterFrame)
        )
        
        self.animationFrame.add(to: .main, forMode: .default)
        self.animationFrame.isPaused = true
        
    }
    
    
    @objc func onEnterFrame(animationFrame: CADisplayLink) {
        
        if ( abs(self.index.center.y - self.wheel.center.y) < 0.5){
            self.index.center = CGPoint(
                x : self.index.center.x,
                y : self.wheel.center.y
            )
            self.animationFrame.isPaused = true
        }else{
            self.index.center = CGPoint(
                x : self.index.center.x,
                y : self.index.center.y - (self.index.center.y - self.wheel.center.y) * 0.22
            )
        }
        
        self.sendPitchBend(self.wheelValue())
        
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .ended {
            self.animationFrame.isPaused = false
        } else {
            self.animationFrame.isPaused = true
            
            let translation = gesture.translation(in: view)
            let y = index.center.y + translation.y
            let maxY = wheel.frame.maxY
            let minY = wheel.frame.origin.y
            
            index.center = CGPoint( x: index.center.x, y: y.clamped(to: minY...maxY))
            self.sendPitchBend(self.wheelValue())
        }
        gesture.setTranslation(.zero, in: view)
    }
    
    func wheelValue() -> Float{
        return (1 - Float((self.index.center.y - self.wheel.frame.origin.y) / self.wheel.frame.size.height )) * 16383
    }
    
    func sendPitchBend(_ value: Float) {
        
        midi.sendPitchBendMessage(value: UInt16(value))
        
    }
    
    
}
