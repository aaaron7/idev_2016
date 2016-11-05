//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


//FRP PART
class Stream<a>{
    var closures : [(a)->Void] = []
    
    func subscribleNext(f : @escaping (_ value : a)->Void){
        closures.append(f)
    }
    
    func setVal(newValue : a)
    {
        for f in closures{
            f(newValue)
        }
    }
    
    func map<b>(f : @escaping (a) -> b) -> Stream<b>
    {
        let newStream = Stream<b>()
        
        self.subscribleNext { (x) in
            newStream.setVal(newValue: f(x))
        }
        
        return newStream
    }
}

struct Model{
    var pos : Stream<Float>
}

struct VirtualView{
    var pos : Stream<Float>
}

enum Action{
    case MouseMove(Float)
}

func Map(m : Model)->VirtualView{
    return VirtualView(pos : m.pos)
}

func Update(m : Model, a : Action) -> Model{
    switch a {
    case .MouseMove(let newPos):
        m.pos.setVal(newValue: newPos)
        break
    }
    return m
}

func Render(v : VirtualView) -> UIView{
    let view = UIView()
    
    v.pos.subscribleNext { (pos) in
        view.frame = CGRect(x: 0, y: Int(pos), width: 100, height: 100)
        print ("move view to \(pos)")
    }
    
    return view;
}



let m = Model(pos: Stream())
let vv = Map(m: m)
let view = Render(v: vv)

Update(m: m, a: .MouseMove(130))

let mousePos : Stream<Float> = Stream()
let mousePosReporter : Stream<String> = mousePos.map { (pos) -> String in
    return "current pos is \(pos)"
}

mousePosReporter.subscribleNext { (str) in
    print(str)
}

mousePos.setVal(newValue: 1.0)
mousePos.setVal(newValue: 2.0)