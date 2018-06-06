---
title: 'LeetCode Question: Palindrome Number'
date: 2018-06-06 23:03:08
categories: LeetCode
tags: LeetCode
---

Palindrome Number

Determine whether an integer is a palindrome. An integer is a palindrome when it reads the same backward as forward.


Example 1:

```
Input: 121
Output: true
```

Example 2:

```
Input: -121
Output: false
Explanation: From left to right, it reads -121. From right to left, it becomes 121-. Therefore it is not a palindrome.
```

Example 3:

```
Input: 10
Output: false
Explanation: Reads 01 from right to left. Therefore it is not a palindrome.
```

Follow up:
Coud you solve it without converting the integer to a string?

This is an easy question.

Here is my answer:

```
/**
 * @param {number} x
 * @return {boolean}
 */
var isPalindrome = function(x) {
    if (x < 0) return false;
    let t = 0;
    let x1 = x;
    while(x > 0) {
        t = t * 10 + x % 10;
        x = Math.floor(x / 10);
    }
    return t === x1;
};
```

My runtime :

![](https://gw.alicdn.com/tfs/TB1M_ulwntYBeNjy1XdXXXXyVXa-2384-1172.png)

You can see, my runtime is 352 ms, see another best answer(244ms):

```
/**
 * @param {number} x
 * @return {boolean}
 */
var isPalindrome = function(x) {
   if(x < 0 || (x % 10 == 0 && x != 0)) return false;
    let reverseNumber = 0;
    while(x > reverseNumber){ // pay attention to this code line, it's awesome!!!
        reverseNumber = reverseNumber * 10 + x % 10;
        x /= 10;
        x = Math.floor(x);
    }
    return x == reverseNumber || x == Math.floor(reverseNumber / 10);
};
```