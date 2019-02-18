# AnimationSeries

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)


Easy way to create a chain of animation. <br />
ex) Animation3 = (Animation1 + Animation2) * 3 <br />


![](https://github.com/gearmamn06/AnimationSeries/blob/master/AnimationSeries-Demo/AnimationSeries-Demo/demo.gif)


## Requirements

iOS 10.0+ 


## Installation

Add AnimationSeries.framework file to the project you want to use. (Check "copy items if needed")



## Why AnimationSeries?

Using repetitive animation in an iOS project is not easy. <br />
For example, to write an animation code that repeats a blinking of a view three times:

```swift

    private func blinkView3times() {
        func appear(_ v: UIView, duration: TimeInterval, completed: ((Bool) -> Void)?) {
            UIView.animate(withDuration: duration, animations: {
                v.alpha = 1.0
            }, completion: completed)
        }
        
        func disappear(_ v: UIView, duration: TimeInterval, completed: ((Bool) -> Void)?) {
            UIView.animate(withDuration: duration, animations: {
                v.alpha = 0.0
            }, completion: completed)
        }
        
        func blink(_ v: UIView, duration: TimeInterval, completed: ((Bool) -> Void)?) {
            disappear(v, duration: 1.0, completed: { _ in
                appear(v, duration: 1.0, completed: completed)
            })
        }
        
        blink(mView, duration: 1.0, completed: { _ in
            blink(self.mView, duration: 1.0, completed: { _ in
                blink(self.mView, duration: 1.0, completed: nil)
            })
        })
    }

```

What if you have to blink the view 100 times? This way is not cool.. Or you could solve the problem by giving a delay to each animation in a loop. But it is cumbersome to calculate. <br /> <br />
We can use AnimationSeries to solve the problem more intuitively.

```swift

    private func blinkView100times() {
        let blink = myView.disappear(duration: 1.0) + myView.appear(duration: 1.0)
        let anim = blink * 100
        anim.start()
    }

```

How is it? Does this look more intuitive and simple? <br />
AnimationSeries was made under the same difficulties as above. With this you can make the view animation easier.


## The Basics

There are default animations declared in this project at view extension.(.appear, .disappear, .discolor, .move, .rotate, sizing) <br />
These animation functions could be connected using the + (sequential connection) and * (repetition) operators.
Calling the start function on the associated animation instance starts a series of animations.


### Single animation

One of the following animations returns a Recursion instance. Calling the start function starts the animation. By registering the onNext callback of the Recursion instance, you can get the end callback of the animation.

```swift

    /// view.alpha -> 1.0 with flat parameters
    public func appear(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> Recursion {
        let anim = Appear(self, params: AnimationParameter(duration, delay: delay, options: options), complete)
        return anim
    }


    /// view.alpha -> 1.0 with AnimationParameter
    public func appear(_ params: AnimationParameter, _ complete: CompleteCallback? = nil) -> Recursion {
        return self.appear(duration: params.duration, delay: params.delay, options: params.options, complete)
    }

```
(AnimationParameter is a struct that contains time, delay, and options.)


### Combine animations

Recursion instances can be combined with other Recursion instances or RecursionSeries instances using the + operator <br />
Combined instances return a new RecursionSeries. <br />
Calling the start method of a new object starts a series of animations. Similarly, registering a new object's onNext callback allows you to get a callback that is called after all animation has finished. <br />
(If you register a CompleteCallback to a single animation, you can get a callback when it ends.)

```swift

    private func startInitialAnim() {
        let anim = animView.sizing(scale: (40, 40), duration: 0) + animView.sizing(scale: (0.6, 0.6), duration: 1.6, { _ in
            print("shrink(single animation) end.")
        }) + animView.sizing(scale: (1.0, 1.0), duration: 0.3)
        
        anim.onNext = {
            print("Intial animation(animation series) end.")
        }
        anim.start()
    }

```


### Loop animation

RecursionSeries instances can be repeated using the * operator.

```swift
    let singleCycle = view.discolor(to: .orange, duration: 1) + view.discolor(to: .yellow, duration: 1) + view.discolor(to: .green, duration: 1) + view.discolor(to: .blue, duration: 1) + view.discolor(to: .purple, duration: 1)

    let repeating = singleCycle * 10
    repeating.start()

```
* Recursion instances are not repeated. 


### Clear Animation

You can use the clear function to stop the animation.(Additional work is required to return the view to its original appearance.)

```swift

    private func clearCurrentAnimation() {
        self.currentAnimations.forEach{ $0.clear() }
        self.initializeView()
    }

    private func initializeView() {
        animView.transform = CGAffineTransform(rotationAngle: 0)
        animView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        animView.transform = CGAffineTransform(translationX: 0, y: 0)
        animView.alpha = 1.0
        animView.backgroundColor = .red
    }

```

### Caution

All Recursable(Recursion or RecursionSeries) instances are not restartable after clear is called. (It will probably stop again at the point where it was previously terminated.) <br />
It is also a reference type, so it is not copied.

```swift
 
    private func wrongUsage() {
        
        // wrong: blink will not be copied
        let blink = animView.disappear(duration: 1) + animView.appear(duration: 1)
        let blinks3Times = blink + blink + blink
        blinks3Times.start()
    }

```


## Customizing

You can create a class that inherits AnimationSeries to define the animation you want. Or add an animation to the extension of the view.

```swift

    import UIKit
    import AnimationSeries

    extension UIView {
        
        public func move(path: [(CGPoint, AnimationParameter)]) -> RecursionSeries? {
            guard !path.isEmpty else { return nil }
            var sender: RecursionSeries!
            path.forEach { tp in
                if sender == nil {
                    sender = self.move(position: tp.0, params: tp.1) + self.move(position: tp.0, params: AnimationParameter(0.0))
                }else{
                    sender = sender + self.move(position: tp.0, params: tp.1)
                }
            }
            return sender
        }
        
    }

    ....

    private func customMoveAnimation() {
        let params = AnimationParameter(0.2)
        let paths = (0..<10).reduce(into: [(CGPoint, AnimationParameter)](), { ary, n in
            ary.append((CGPoint(x: ary.count + 10, y: 0), params))
        })
        let anim = animView.move(path: paths)
        anim?.onNext = {
            print("moving all end..")
        }
        anim?.start()
    }

```



