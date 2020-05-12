import AudioKit
import UIKit


class ModViewController: UIViewController, AKMIDIListener {
    
    //MARK: Properties
    @IBOutlet weak var wheel: UIView!
    @IBOutlet weak var index: UIView!
    @IBOutlet weak var fill: UIView!
    
    var midi = AudioKit.midi
    
    var ccToSend: Int = 1
    var ccChanToSend: Int = 0
//
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
        index.center.y = wheel.center.y
        
        fill.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        fill.center.y = wheel.frame.maxY
        
        fill.transform = CGAffineTransform(scaleX: 1, y: 0.5)
        
        midi.openOutput()
        
        self.animationFrame = CADisplayLink(
            target: self,
            selector: #selector(onEnterFrame)
        )
        
    }
    
    @objc func onEnterFrame(animationFrame: CADisplayLink) {}
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
//        print("pancake")
        
        let val = self.wheelValue()
        
        let translation = gesture.translation(in: view)
        
        let y = index.center.y + translation.y
        let maxY = wheel.frame.maxY
        let minY = wheel.frame.origin.y
        
        index.center = CGPoint( x: index.center.x, y: y.clamped(to: minY...maxY))
        fill.transform = CGAffineTransform(scaleX: 1, y: CGFloat(val))
        self.sendCC(val * 127)
        
        gesture.setTranslation(.zero, in: view)
    }
    
    func wheelValue() -> Float{
        return (1 - Float((self.index.center.y - self.wheel.frame.origin.y) / self.wheel.frame.size.height ))
    }
    
    func sendCC(_ value: Float) {
        let event = AKMIDIEvent(controllerChange: MIDIByte(ccToSend), value: MIDIByte(value), channel: MIDIChannel(ccChanToSend))
        midi.sendEvent(event)
    }
    
    
}
