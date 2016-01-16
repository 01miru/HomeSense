//
//  HomeSense.swift
//  HomeSense
//
//  Created by Dorian Nowak on 12.01.2016.
//  Copyright © 2016 Dorian Nowak. All rights reserved.
//

import Foundation

class HomeSense {
    
    class func matchesForRegexInText(text: NSString!) -> [String] {
        
        do{
            let pattern = "H:(\\d{2}\\.\\d{2}) T:(\\d{2}\\.\\d{2})"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            if let match = regex.firstMatchInString(text as String, options: [], range: NSMakeRange(0, text.length)) {
                let temperature = text.substringWithRange(match.rangeAtIndex(2))
                let humidity = text.substringWithRange(match.rangeAtIndex(1))
                return [temperature, humidity]
            }
        } catch let error as NSError {
            print(error)
        }

        return []
    }
    
    class func getHumidity (value: NSData) -> String {
        
        if let val = NSString(data: value, encoding: NSUTF8StringEncoding){
            let hum = self.matchesForRegexInText(val)[1]
            let humpArr = hum.characters.split{$0 == "."}.map(String.init)
            
            // If you want to show two decimal places values, return hum instead humpArr[0]
            return humpArr[0]
        }
        return "-"
        
    }
    
    class func getTemperature (value: NSData) -> String {
        
        if let val = NSString(data: value, encoding: NSUTF8StringEncoding){
            let temp = self.matchesForRegexInText(val)[0]
            let tempArr = temp.characters.split{$0 == "."}.map(String.init)
            
            // If you want to show two decimal places values, return temp instead tempArr[0]
            return tempArr[0]
        }
        return "-"
        
    }
}
