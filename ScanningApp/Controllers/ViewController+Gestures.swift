/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Gesture interaction methods for the main view controller.
*/

import UIKit
import SceneKit

extension ViewController: UIGestureRecognizerDelegate {
        
    @IBAction func didTap(_ gesture: UITapGestureRecognizer) {
        print("gesture didTap")
        if state == .scanning {
            scan?.didTap(gesture)
        }
        
        instructionsVisible = false
    }
    
    @IBAction func didOneFingerPan(_ gesture: UIPanGestureRecognizer) {
        print("gesture didOneFingerPan")
        if state == .scanning {
            scan?.didOneFingerPan(gesture)
        }
        
        instructionsVisible = false
    }
    
    @IBAction func didTwoFingerPan(_ gesture: ThresholdPanGestureRecognizer) {
        print("gesture didTwoFingerPan")
        if state == .scanning {
            scan?.didTwoFingerPan(gesture)
        }
        
        instructionsVisible = false
    }
    
    @IBAction func didRotate(_ gesture: ThresholdRotationGestureRecognizer) {
        print("gesture didRotate")
        if state == .scanning {
            scan?.didRotate(gesture)
        }
        
        instructionsVisible = false
    }
    
    @IBAction func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        print("gesture didPress")
        if state == .scanning {
            scan?.didLongPress(gesture)
        }
        
        instructionsVisible = false
    }
    
    @IBAction func didPinch(_ gesture: ThresholdPinchGestureRecognizer) {
        print("gesture didPinch")
        if state == .scanning {
            scan?.didPinch(gesture)
        }
        
        instructionsVisible = false
    }
    
    func gestureRecognizer(_ first: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith second: UIGestureRecognizer) -> Bool {
        if first is UIRotationGestureRecognizer && second is UIPinchGestureRecognizer {
            return true
        } else if first is UIRotationGestureRecognizer && second is UIPanGestureRecognizer {
            return true
        } else if first is UIPinchGestureRecognizer && second is UIRotationGestureRecognizer {
            return true
        } else if first is UIPinchGestureRecognizer && second is UIPanGestureRecognizer {
            return true
        } else if first is UIPanGestureRecognizer && second is UIPinchGestureRecognizer {
            return true
        } else if first is UIPanGestureRecognizer && second is UIRotationGestureRecognizer {
            return true
        }
        return false
    }
}
