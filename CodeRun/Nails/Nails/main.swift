//
//  main.swift
//  Nails
//
//  Created by Alexander Kurbatov on 27.07.2023.
//
/*
Для чтения входных данных необходимо получить их
из стандартного потока ввода (stdin).
Данные во входном потоке соответствуют описанному
в условии формату. Обычно входные данные состоят
из нескольких строк.

Можно использовать несколько методов:
* readLine() -- читает одну строку из потока;
* readLine(strippingNewline: Bool) -- читает одну строку без символа переноса строки из потока;
* readLine()?.split(separator: " ") -- читает одну строку и делит ее на слова, используя заданный разделитель.

Чтобы прочитать из строки стандартного потока:
* число -- let var = Int(readLine()!)!;
* строку -- let svar = readLine()!;
* массив чисел известной длины --
let arr = readLine()!.split(separator: " ").map{ Int($0)! };
* последовательность слов до конца файла --
var sarr = [String]();
while let line = readLine() {
    let words = line.split(separator: " ")
    sarr += words.map { String($0) }
}

Чтобы вывести результат в стандартный поток вывода (stdout),
можно использовать функцию print().

Возможное решение задачи "Вычислите сумму A+B":
let line = readLine()!
let numbers = line.split(separator: " ")
print(Int(numbers[0])! + Int(numbers[1])!)
*/ 

import Foundation

struct EnterData {
    
    let numberOfDancersGroops: Int
    var groups: [Int]
    let numberOfKindsRooms: Int
    var rooms: [Int: Int]
    
    mutating func findOpportunity() -> String{
        var answer: String = ""
        
        // сортируем группы по количеству танцовщиц
        groups.sort(by: >)
        
        for group in groups {
//            print(rooms)
//            print(group)
            if rooms.isEmpty {
                answer = "No"
                return answer
            }
            for key in rooms.keys.sorted(by: >) {
                print(key)
                if group > key || rooms[key] == nil {
                    answer = "No"
                    return answer
                } else {
                    rooms[key] = rooms[key]! - 1
                    if rooms[key] == 0 {
                        rooms[key] = nil
                    }
                    break
                }
            }
        }
        
        answer = "Yes"
        
        return answer
    }
    
}

final class Application {
    
    func main() {
        let reader = DataReader()
        var enterData = reader.read()
        let result = enterData.findOpportunity()
        
        print(result)
    }
    
    // MARK: - Private
    
    private class DataReader {
        
        
        
        func read() -> EnterData {
            print("Введите число групп танцовщиц:")
            let firstString = readLine() ?? ""
            let numberOfDancersGroops = Int(firstString) ?? 0
            print("Введите количество танцовщиц в i-ой группе:")
            let secondString = readLine() ?? ""
            let groups = secondString.split(separator: " ").map { Int($0)! }
            print("Введите количество типов комнат:")
            let thirdString = readLine() ?? ""
            let numberOfKindsRooms = Int(thirdString) ?? 0
            print("Введите пару тип комнаты-количество таких комнат:")
            
            var rooms: [Int: Int] = [:]
            for _ in 0..<numberOfKindsRooms {
                let room = readLine()!.split(separator: " ").map { Int($0)! }
                if rooms[room[0]] == nil {
                    rooms[room[0]] = room[1]
                } else {
                    rooms[room[0]]! += room[1]
                    
                }
            }
            
            
            let enterData = EnterData(numberOfDancersGroops: numberOfDancersGroops, groups: groups, numberOfKindsRooms: numberOfKindsRooms, rooms: rooms)
            
            return enterData
        }
    }
}

let application = Application()
application.main()


