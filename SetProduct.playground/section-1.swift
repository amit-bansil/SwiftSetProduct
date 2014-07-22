func setProduct<AT: Sequence, BT: Sequence>(a: AT, b: BT) ->
    SequenceOf<(AT.GeneratorType.Element, BT.GeneratorType.Element)> {
        
    typealias ReturnTuple = (AT.GeneratorType.Element, BT.GeneratorType.Element)
    return SequenceOf<ReturnTuple> {
        ()->GeneratorOf<ReturnTuple> in //why is this required?
        var generatorA = a.generate()
        var currentA = generatorA.next()
        var generatorB = b.generate()
        
        return GeneratorOf<ReturnTuple> {
            var currentB = generatorB.next()
            if !currentB {
                currentA = generatorA.next()
                generatorB = b.generate()
                currentB = generatorB.next()
            }
            if !currentB {
                return nil
            }else if !currentA {
                return nil
            }else{
                return (currentA!, currentB!)
            }
        }
    }
}

func setProduct<AT: Sequence, BT: Sequence, CT: Sequence>(a: AT, b: BT, c: CT) ->
    SequenceOf<(AT.GeneratorType.Element, BT.GeneratorType.Element, CT.GeneratorType.Element)> {
    
    let aTimesB = setProduct(a,b)
    let ret = setProduct(aTimesB, c)
        
    //flatten ret
    typealias ReturnTuple = (AT.GeneratorType.Element, BT.GeneratorType.Element, CT.GeneratorType.Element)
    return SequenceOf<ReturnTuple> {
        ()->GeneratorOf<ReturnTuple> in //why is this required?
        var generator = ret.generate()
        return GeneratorOf<ReturnTuple>{
            var next =  generator.next()
            if next {
                return (next!.0.0, next!.0.1, next!.1)
            }else{
                return nil
            }
        }
    }
}

class CollectionFromTuple: Collection {
    let target:Mirror
    init(_ target:Any){
        self.target = reflect(target)
    }
    subscript (i: Int) -> Any {
        get{
            return target[i].1.value
        }
    }
    var startIndex: Int {
    get{
        return 0
    }
    }
    var endIndex: Int {
    get{
        return target.count
    }
    }
    func generate() -> GeneratorOf<Any>{
        var index = 0
        return GeneratorOf<Any> {
            if index >= self.target.count {
                return nil
            }
            let ret = self[index]
            ++index
            return ret
        }
    }
}

for e in setProduct(["a", "b", "c"], 4...8) {
    println(e)
}

for e in setProduct(CollectionFromTuple(("a", "b", "c")), 4...8, [true, false]) {
    println(e)
}
//fails
let listWithNils:[Int?] = [1, nil, 3]
for e in setProduct(listWithNils, [true, false], CollectionFromTuple(("a", "b", "c"))) {
    println(e)
}