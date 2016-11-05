//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
struct Parser<a>{
    let p : (String) -> [(a,String)]
    
}


// Utility function
func isSpace(_ c : Character) -> Bool{
    let s = String(c)
    let result = s.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines)
    return result != nil
}

func isDigit(_ c : Character) -> Bool{
    let s = String(c)
    return Int(s) != nil
}

func isAlpha(_ c : Character) -> Bool{
    if c >= "a" && c <= "z" || c >= "A" && c <= "Z"{
        return true
    }else{
        return false
    }
}

//MARK: Basic Element

infix operator >>= {associativity left precedence 150}

func >>= <a,b>(p : Parser<a>, f : @escaping (a)->Parser<b>) -> Parser<b>{
    return Parser { cs in
        let p1 = parse(p, input: cs)
        guard p1.count>0 else{
            return []
        }
        let p = p1[0]
        
        let p2 = parse(f(p.0), input: p.1)
        guard p2.count > 0 else{
            return []
        }
        
        return p2
    }
}

func mzero<a>()->Parser<a>{
    return Parser { xs in [] }
}

func pure<a>( _ item : a) -> Parser<a>{
    return Parser { cs in [(item,cs)] }
}

func satify(_ condition : @escaping (Character) -> Bool) -> Parser<Character>{
    return Parser { x in
        guard let head = x.characters.first , condition(head) else{
            return []
        }
        return [(head,String(x.characters.dropFirst()))]
    }
}



//MARK: combinator

infix operator +++ : Oper

precedencegroup Oper {
    associativity:left
    higherThan : AdditionPrecedence
}
func +++ <a>(l : Parser<a>, r:Parser<a>) -> Parser<a>   {
    return Parser { x in
        if l.p(x).count > 0{
            return l.p(x)
        }else{
            return r.p(x)
        }
    }
}



func many<a>(_ p: Parser<a>) -> Parser<[a]>{
    return many1(p) +++ pure([])
}

func many1<a>(_ p : Parser<a>) -> Parser<[a]>{
    return p >>= { x in
        many(p) >>= { xs in
            pure([x] + xs)
        }
    }
}

func parserChar(_ c : Character) -> Parser<Character>{
    return Parser { x in
        guard let head = x.characters.first , head == c else{
            return []
        }
        return [(c,String(x.characters.dropFirst()))]
    }
}

func parse<a>(_ parser : Parser<a> , input: String) -> [(a,String)]{
    var result :[(a,String)] = []
    for (x,s) in parser.p(input){
        result.append((x,s))
    }
    return result
}



//MARK: handle string
func string(_ str : String) -> Parser<String>{
    guard str != "" else{
        return pure("")
    }
    
    let head = str.characters.first!
    return parserChar(head) >>= { c in
        string(String(str.characters.dropFirst())) >>= { cs in
            let result = [c] + cs.characters
            return pure(String(result))
        }
    }
}

func space()->Parser<String>{
    return many(satify(isSpace)) >>= { x in pure("") }
}

func symbol(_ sym : String) -> Parser<String>{
    return string(sym) >>= { sym in
        space() >>= { _ in
            pure(sym)
        }
    }
}

func digit() -> Parser<Int>{
    return satify(isDigit) >>= { x in
        pure(Int(String(x))!)
    }
}

func number() -> Parser<Int>{
    return many1(digit()) >>= { cs in
        space() >>= { _ in
            let sum = cs.reduce(0, { (exp1 , exp2 ) -> Int in
                return exp1 * 10 + exp2
            })
            return pure(sum)
        }
    }
}

// DSL PART
// let v = Generate("UIView:0,0,200,200:hidden=NO:color=red")

indirect enum ViewAst
{
    case ViewType(String)
    case Frame(Int,Int,Int,Int)
    case PropertyAssign(String,String)
    case Connector(ViewAst,ViewAst)
}

let isNotSpecChar = { (c:Character) -> Bool in
    if c >= "a" && c <= "z" || c >= "A" && c <= "Z" || c >= "0" && c <= "9"{
        return true
    }else{
        return false
    }
}

func identifier()->Parser<String>{
    return many1(satify(isNotSpecChar)) >>= { cs in
        pure(String(cs))
    }
}
func viewType()->Parser<ViewAst>{
    return identifier() >>= { str in
        pure(.ViewType(str))
    }
}

func numberItem()->Parser<Int>{
    return number() >>= { x in
        many(parserChar(",")) >>= { _ in
            pure(x)
        }
    }
}

func frame()->Parser<ViewAst>{
    return colon() >>= { _ in
        many1(numberItem()) >>= { xs in
            pure(.Frame(xs[0],xs[1],xs[2],xs[3]))
        }
    }
}

func propertyAssign()->Parser<ViewAst>{
    return colon() >>= { _ in
        identifier() >>= { left in
            parserChar("=") >>= { _ in
                identifier() >>= { right in
                    pure(.PropertyAssign(left,right))
                }
            }
        }
    }
}

func connector()->Parser<ViewAst>{
    return viewDef() >>= { left in
        viewDefFull() >>= { right in
            pure(.Connector(left, right))
        }
    }
}

func colon()->Parser<String>{
    return parserChar(":") >>= { _ in
        pure("")
    }
}

func viewDef()->Parser<ViewAst>{
    return viewType() +++ frame() +++ propertyAssign()
}

func viewDefFull()->Parser<ViewAst>{
    return connector() +++ viewDef()
}

let r = parse(viewDefFull(), input: "UIView:0,0,200,200:hidden=NO:color=red")

print (r)

