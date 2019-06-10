# AnimationSeries

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)



Easy way to create a chain of animation. <br />
```swift
func drunkAnimation() {        
    let headbanging = 🧠.rotate(degree: 360, duration: 0.1)
    let stumble = (🚶.move(position: CGPoint(x: -10, y: 0), duration: 0.5) + 🚶.move(position: CGPoint(x: 10, y: 0), duration: 0.5)) * 10
    let puke = (🤢.sizing(scale: (100, 100), duration: 0.4) + 🤢.sizing(scale: (0.1, 0.1), duration: 0.2)) * 10
        
    let drunk = (headbanging | stumble | puke) * Int.max
    drunk.start()
 }
```
<br /><br />

![](https://github.com/gearmamn06/AnimationSeries/blob/master/AnimationSeries-Demo/AnimationSeries-Demo/demo.gif)


## Requirements

iOS 10.0+ 


## Installation
### Cocoapods
```ruby
pod 'AnimationSeries'
```
Or add AnimationSeries.framework file to the project you want to use. (Check "copy items if needed")



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


### Single animation

One of the following animations returns a AnimationSeries instance. Call the start function to start the animation. By setting the complete callback, you can get the end callback of the animation.

```swift

/// view.alpha -> 1.0 with flat parameters
    public func appear(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete:   CompleteCallback? = nil) -> AnimationSeries {
        let anim = Appear(self, params:  ViewAnimation.Parameter(duration, delay: delay, options: options), complete)
        return anim
    }
    
    
    /// view.alpha -> 1.0 with AnimationParameter
    public func appear(_ params:  ViewAnimation.Parameter, _ complete: CompleteCallback? = nil) -> AnimationSeries {
        return self.appear(duration: params.duration, delay: params.delay, options: params.options, complete)
    }
```
(AnimationParameter is a struct that contains time, delay, and options.)


### Combine animations

AnimationSeries instances can be combined with other AnimationSeries instances using the + operator. <br />
Combined instances return a new AnimationSeries. <br />
Call the start method of a new instance to start a series of animations. Similarly, setting a new instance's animationDidFinish callback allows you to get a callback that is called after all animation has finished. <br />
(If you set a CompleteCallback to a single AnimationSeries, you can get a callback when it ends.)

```swift

    private func startInitialAnim() {
        let anim = animView.sizing(scale: (40, 40), duration: 0) + animView.sizing(scale: (0.6, 0.6), duration: 1.6, { _ in
            print("shrink(single animation) end.")
        }) + animView.sizing(scale: (1.0, 1.0), duration: 0.3)

        anim.animationDidFinish = { [weak anim] in
            print("Intial animation(animation series) end. -> release point")
            AnimationPool.shared.release(anim)
        }
        anim.start()
    }

```

### Parallel animation

If you want certain animations to start at the same time, Connect the animations with the | operator <br />

```swift
    let drunk = (headbanging | stumble | puke) * Int.max
```

### Loop animation

AnimationSeries instances can be repeated using the * operator.

```swift
    let series = view.discolor(to: .orange, duration: 1) + view.discolor(to: .yellow, duration: 1) + view.discolor(to: .green, duration: 1) + view.discolor(to: .blue, duration: 1) + view.discolor(to: .purple, duration: 1)

    let repeating = series * 10
    repeating.start()

```


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

### Memory Issue

When a AnimationSeries instance is created by using the + or * operators, AnimationSeries instances participating in the series are kept in static memory to prevent them from making circular references or to prevent them from being released from memory before the operation. <br /><br />

After an animation end, it is highly recommended to release from memory as follows.
(AnimationSeries.clear function also do release memory)

```swift

    let anim = self.view.disappear(duration: 1, delay: 0.0, options: .curveLinear, {  _ in
        // When the animation finishes, the completeCallback will be called.
        print("disappear animation end")
    })

    // single animation flushing
    anim.animationDidFinish = { [weak anim] in
        // animationDidFinish closure is used to connect with the following animation(recurable) instance.
        // If no animation is linked behind, you can flush it from the static memory when this closure is called.
        AnimationPool.shared.release(anim)
    }


    let series = (self.view.disappear(duration: 1) + self.view.appear(duration: 1)) * 10
    series.animationDidFinish = { [weak series] in
        // animationDidFinish closure of the series is called when the animation ends.
        // In this case, release the series from the static memory.
        AnimationPool.shared.release(anim)
    }
    series.start()

```

### Caution

All AnimationSeries instances are not restartable after clear is called.  <br />
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
        
        public func move(path: [(CGPoint, ViewAnimation.Parameter)]) -> AnimationSeries? {
            guard !path.isEmpty else { return nil }
            var sender: AnimationSeries!
            path.forEach { tp in
                if sender == nil {
                sender = self.move(position: tp.0, params: tp.1) + self.move(position: tp.0, params: ViewAnimation.Parameter(0.0))
                }else{
                    sender = sender + self.move(position: tp.0, params: tp.1)
                }
            }
            return sender
        }
        
    }

    ....

    private func customMoveAnimation() {
        let params = ViewAnimation.Parameter(0.2)
        let paths = (0..<10).reduce(into: [(CGPoint, ViewAnimation.Parameter)](), { ary, n in
            ary.append((CGPoint(x: ary.count + 10, y: 0), params))
        })
        let anim = animView.move(path: paths)
        anim?.animationDidFinish = { [weak anim] in
            print("moving all end..")
            AnimationPool.shared.release(anim)
        }
        anim?.start()
    }

```



