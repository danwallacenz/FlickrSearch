//
//  OrderedDictionary.swift
//  FlickrSearch
//
//  Created by Daniel Wallace on 6/11/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation


//The object is going to be a struct because it should have value semantics.
//The elements inside the angled brackets are the type parameters of the generic. KeyType and ValueType are not types themselves, but rather become parameters that you can use in place of types within the struct’s definition.
struct OrderedDictionary<KeyType:Hashable, ValueType> {

    
    //  This declares two properties, as described, and also two type aliases, which are a way to give a new name to an existing type. Here, you give aliases to the array and dictionary types for the backing array and dictionary, respectively. Type aliases are a great way to take a complex type and give it a much shorter name.
    typealias ArrayType = [KeyType]
    typealias DictionaryType = [KeyType: ValueType]
    
    var array = ArrayType()
    var dictionary = DictionaryType()
    
    // A computed property.
    var count: Int {
        return self.array.count
    }
    
    
    //    Structs are designed to be immutable by default, meaning you ordinarily can’t mutate struct member variables in an instance method. Since that is quite limiting, you can add the mutating keyword to tell the compiler that the method is allowed to mutate state in the struct. This helps the compiler make decisions about when to take copies of structs (they are copy-on-write) and also helps document the API.
    mutating func insert(value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType?
    {
        var adjustedIndex = index
        
        //  Pass the key to the indexer of the Dictionary, which returns the existing value if one already exists for that key. This insert method emulates the same behavior as the Dictionary’s updateValue and therefore saves the existing value for the key.
        let existingValue = self.dictionary[key]
        
        // If there is an existing value, then and only then does the method find the index into the array for that key.
        if existingValue != nil {
            let existingIndex = find(self.array, key)!
            
            //  If the existing key is before the insertion index, then you need to adjust the insertion index because you’re about to remove the existing key.
            if existingIndex < index {
                adjustedIndex--
            }
            self.array.removeAtIndex(existingIndex)
        }
        // Update the array and dictionary, as appropriate.
        self.array.insert(key, atIndex: adjustedIndex)
        self.dictionary[key] = value
        
        return existingValue
    }
    
    //  This is a function that mutates the internal state of the struct, and you therefore mark it as such. The name removeAtIndex matches the method on Array. It’s a good idea to consider mirroring the APIs of the system library when appropriate. It helps make developers using your API feel at home on the platform.
    mutating func removeAtIndex(index: Int) -> (KeyType, ValueType)
    {
        // Check the index to see if it’s within the bounds of the array.
        precondition(index < self.array.count, "Index out-of-bounds")
        
        
        //  Obtain the key from the array for the given index while at the same time removing the value from the array.
        let key = self.array.removeAtIndex(index)
        
        
        //  Remove the value for that key from the dictionary, which also returns the value that was present. The dictionary might not contain a value for the given key, so removeValueForKey returns an optional. In this case, you know that the dictionary will contain a value for the given key, because the only method that can add to the dictionary is your own insert(_:forKey:atIndex:), which you wrote. Thus you can immediately unwrap the optional with ! knowing there will be a value there.
        let value = self.dictionary.removeValueForKey(key)!
        
        //  Return the key and value in a tuple. This parallels the behavior of Array removeAtIndex and Dictionary removeValueForKey, which return the existing values.
        return (key, value)
    }
    
    
    //  Index into the ordered dictionary as if it were a normal dictionary.
    
    //  This is how you add subscript behavior. Instead of func or var, you use the subscript keyword. The parameter, in this case key, defines the object that you expect to appear inside the square brackets.
    subscript(key: KeyType) -> ValueType? {
        
        //  Subscripts can comprise setters and getters, just like computed properties can. Notice that this one has both  a get and a set closure, defining the getter and setter, respectively.
        get{
            return self.dictionary[key]
        }
        
        set {
            if let index = find(self.array, key) {
                // do nothing
            } else {
                self.array.append(key)
            }
            
            // Implicitly named variable newValue.
            self.dictionary[key] = newValue
        }
    }
    
    // Accessing by index, as with an array
    subscript(index: Int) -> (KeyType, ValueType) {
        
        get {
            precondition(index < self.array.count, "Index out-of-bounds")
            
            let key = self.array[index]
            
            let value = self.dictionary[key]!
            
            return (key, value)
        }
        
        set { // does this work? TEST
            precondition(index < self.array.count, "Index out-of-bounds")
            
            let (key, value) = newValue
            if let index = find(self.array, key) {
                // do nothing
            } else {
                self.array.append(key)
            }

             self.dictionary[key] = newValue
        }
    }
    
}






























