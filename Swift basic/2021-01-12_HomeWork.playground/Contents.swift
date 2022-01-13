import UIKit

/*
 Sort Array By Parity

Solution
Given an integer array nums, move all the even integers at the beginning of the array followed by all the odd integers.

Return any array that satisfies this condition.



Example 1:
Input: nums = [3,1,2,4]
Output: [2,4,3,1]
Explanation: The outputs [4,2,3,1], [2,4,1,3], and [4,2,1,3] would also be accepted.
 
Example 2:
Input: nums = [0]
Output: [0]


Constraints:
1 <= nums.length <= 5000
0 <= nums[i] <= 5000
 */


func sortArrayByParity(_ nums: [Int]) -> [Int] {
    var sortedArr: [Int] = []
    
    var oddArr: [Int] = []
    var evenArr: [Int] = []
    
    for element in nums {
        if element % 2 == 0 {
            oddArr.append(element)
        } else {
            evenArr.append(element)
        }
    }
    sortedArr = oddArr + evenArr
    return sortedArr
}
sortArrayByParity([3,1,2,4])


/*
 LeetCode solution
 */

func sortArrayByParity1(_ nums: [Int]) -> [Int] {
    var sortedArr: [Int] = nums
    var i: Int = 0
    var j: Int = nums.count - 1
    
    while i < j {
        
        if (sortedArr[i] % 2) > (sortedArr[j] % 2) {
            let temp = sortedArr[i]
            sortedArr[i] = sortedArr[j]
            sortedArr[j] = temp
        }
        
        if sortedArr[i] % 2 == 0 { i += 1 }
        if sortedArr[j] % 2 == 1 { j -= 1 }
    }
  
    return sortedArr
}

sortArrayByParity1([3,1,2,4])
