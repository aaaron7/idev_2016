//: Playground - noun: a place where people can play

import UIKit


var str = "Hello, playground"

class Student
{
    var name : String
    var score : Int
    
    init(stuName : String, stuScore : Int)
    {
        name = stuName;
        score = stuScore;
    }
}

//FUNCTIONS PART
class Node<T>
{
    let value : T
    var left : Node? = nil
    var right : Node? = nil
    init(initValue : T)
    {
        value = initValue
    }
}

let root = Node(initValue: "a")
root.left = Node(initValue: "b")
root.right = Node(initValue: "c")
root.right!.left = Node(initValue: "d")

func outputTree(root : Node<String>)
{
    print(root.value)
    
    if let left = root.left{
        outputTree(root: left)
    }
    
    if let right = root.right{
        outputTree(root: right)
    }
}

func outputTreeEx(root : Node<String>, output : ((String) -> Void))
{
    output(root.value)
    
    if let left = root.left{
        outputTree(root: left)
    }
    
    if let right = root.right{
        outputTree(root: right)
    }
}




typealias UserId = Int
typealias User = AnyObject

class DBConnection
{
    func saveString(value : String) -> Void
    {
        
    }
}

func saveStringToDB(db : DBConnection)->(_ value : String)-> Void
{
    return { (value:String) -> Void in
        db.saveString(value: value)
    }
}

func saveStringToDB(db : DBConnection, _ value : String)-> Void
{
    db.saveString(value: value)
}
let db = DBConnection()

outputTreeEx(root: root) { (str) in
    saveStringToDB(db: db, str)
}

outputTreeEx(root: root, output: saveStringToDB(db: db))


//MONAD PART
enum Maybe<a>
{
    case None
    case Some(a)
}


func loadStringFromDB(db : DBConnection) -> Maybe<String>
{
    return .Some("")
}

func getUserByName(db : DBConnection)->(_ name:String) -> Maybe<User>
{
    return { name in
        return .Some(NSObject())
    }
}


func getUserScores(db : DBConnection)->(_ user:User) -> Maybe<Float>
{
    return { _ in
        return .Some(12.3)
    }
}

let result = loadStringFromDB(db: db)
if case .Some(let x) = result
{
    let user = getUserByName(db: db)(x)
    if case .Some(let y) = user
    {
        let score = getUserScores(db: db)(y)
        if case .Some(let z) = score
        {
            print ("Finally got here");
        }
    }
}



func bind<a,b>(left : Maybe<a>, f : ((a)->Maybe<b>)) -> Maybe<b>
{
    if case .Some(let x) = left
    {
        return f(x)
    }
    else
    {
        return .None
    }
}


let r1 = loadStringFromDB(db: db)
let r2 = bind(left: r1, f: getUserByName(db: db))
let r3 = bind(left: r2, f: getUserScores(db: db))

let temp:String? = "123"

temp.flatMap { (x) -> Int? in
    print(x)
    return 3
}

func pure<a>(x : a) -> Maybe<a>
{
    return Maybe.Some(x)
}



func pure<a>(x : a) -> a?
{
    return x
}

func bind<a,b>(x : a?, f : ((a) -> b?)) -> b?
{
    return x.flatMap({ (rx) -> b? in
        f(rx)
    })
}









