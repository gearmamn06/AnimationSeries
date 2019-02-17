# AnimationSeries


Easy way to create a chain of animation.
Animation3 = (Animation1 + Animation2) * 3


## Requirements

iOS 10.0+ 


## Installation

Add AnimationSeries.framework file to the project you want to use. (Check "copy items if needed")



## Why AnimationSeries?

iOS 프로젝트에서 반복적인 애니메이션을 사용하는것은 쉽지않다
가령 한 뷰가 깜빡이는것을 3회 반복하는 애니메이션 코드를 짜려면 기존의 방식으로는 다음과 같이 짤 수 있다

```

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

하지만 만일 뷰를 100번 깜빡여야 한다면 어떨까. 이방법은 쿨하지 않다. 이는 루프를 돌면서 각 애니메이션마다 딜레이를 줘서 해결 할 수 있을것이다.
하지만 그것은 계산하기 번거롭고 우리는 AnimationSeries를 이용하여 더 직관적으로 이를 해결하 수 있다.

```

    private func blinkView3times() {
        let blink = myView.disappear(duration: 1.0) + myView.appear(duration: 1.0)
        let anim = blink * 100
        anim.start()
    }

```

어떤가? 보다 직관적이지 않는가? 계다가 코드가 더 짧아지고 비동기 콜백 체인이 사라졌다
AnimationSeries는 위와같은 고민 하에서 만들어졌다.
이것을 이용하여 너는 뷰 애니메이션을 더 쉽고 간결하게 만들 수 있다.


## The Basics

이 프로젝트에 기본적인 애니메이션(등장, 사라짐, 색상 변화, 이동, 회전, 크기변화)이 extenson으로 선언되어있다.
이 함수들을 +(순차적 연결), * (반복) 연산자를 이용하여 더 직관적으로 연결시켜라
연결된 애니메이션 인스턴스에 start 함수를 콜하면 일렬의 애니메이션이 시작된다.


### 단일 애니메이션

다음과같은 애니메이션 하나는 Recursion 인스턴스를 반환시킨다. 애니메이션의 시작은 start이고 Recursion 인스턴스의 onNext 콜백을 등록하면 이 애니메이션의 종료를 수신 할 수 있다.

```

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
(AnimationParameter은 시간, 딜레이, 옵션을 담는 스트럭이다.)


### 애니메이션 결합

Recursion 인스턴스는 다른 Recursion 인스탄스 및 RecursionSeries 인스턴스와 + 연산자를 이용하여 결합될 수 있다
결합된 인스턴스들은 새로운 RecursionSeries를 반환한다.
이 객체의 start 메소드를 호출하면 일렬의 애니메이션을 시작 한다. 이 객체의 onNext 콜백을 등록하면 모든 애미메이션이 종료한 후 콜백을 받을 수 있다.
(단일 애니메이션에 complete 콜백을 등록하면, 단일 애니메이션이 종료되는 콜백을 받을 수 있다.)

```

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


### 애니메이션 반복

RecursionSeries 객체는 * 연산자를 이용하여 반복될 수 있다.

```
    let singleCycle = view.discolor(to: .orange, duration: 1) + view.discolor(to: .yellow, duration: 1) + view.discolor(to: .green, duration: 1) + view.discolor(to: .blue, duration: 1) + view.discolor(to: .purple, duration: 1)

    let repeating = singleCycle * 10
    repeating.start()

```
* recursion 인스턴스는 반복되지 않는다.(단일 애니메이션 이후 변한 상태가 없기 떄문) 단일 애니메이션의 반복을 원한다면 원상태로 바로 복귀시키는 recursion과 결합시킨 이후(duration = 0) recursionSeries를 만들어 반복을 하여라


### 애니메이션 중지

clear 함수를 이용하여 애니메이션을 종료시켜라 (뷰를 원래상태로 복귀시키려면 추가적인 작업이 필요하다.)

```

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

### 주의사항

모든 Recursable (recursion or recursionSeries) 인스턴스들은 clear가 호출된 이후 이것은 재시작이 불가능하다. (아마 종료된 시점에서 다시 중지될것이다.)
또한 참조형이기 때문에 복사되지 않는다

```
 
    private func wrongUsage() {
        
        // wrong: blink will not be copied
        let blink = animView.disappear(duration: 1) + animView.appear(duration: 1)
        let blinks3Times = blink + blink + blink
        blinks3Times.start()
    }

```


## Customizing

AnimationSeries를 상속받는 커스텀 클래스를 만들어 너가 원하는 애니메이션을 정의할 수 있다. 혹은 view의 extension에 애니메이션을 추가해라

```

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



