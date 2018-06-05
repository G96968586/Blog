---
title: 'LeetCode Questions: Longest Substring Without Repeating Characters'
date: 2018-06-06 00:41:21
categories: LeetCode
tags: LeetCode
---

Given a string, find the length of the longest substring without repeating characters.

Examples:

Given "abcabcbb", the answer is "abc", which the length is 3.

Given "bbbbb", the answer is "b", with the length of 1.

Given "pwwkew", the answer is "wke", with the length of 3. Note that the answer must be a substring, "pwke" is a subsequence and not a substring.

<!-- more -->

My answer:

```
/**
 * @param {string} s
 * @return {number}
 */
// 分析
// abcabcbb = abc abc b b : 3 3 1 1
// bbbbb = b b b b b : 1 1 1 1 1
// pwwkew = pw wke w : 2 3 1
// dvdf = d vdf : 1 3
var lengthOfLongestSubstring = function(s) {
    let stack = [];
    let length = 0;
    let i = 0;
    // 循环字符串
    while(i < s.length) {
        const index = stack.indexOf(s[i]);
        if (~index) {
            if (length < stack.length) {
                length = stack.length;
            }
            stack.splice(0, index + 1);
        }
        stack.push(s[i]);
        i++;
    }
    if (stack.length > length) length = stack.length;
    return length;
};
```
![](https://gw.alicdn.com/tfs/TB1tAf3vMmTBuNjy1XbXXaMrVXa-2418-1066.png)

You can see, my runtime is 128 ms, see another best answer(79ms):

```
/**
 * @param {string} s
 * @return {number}
 */
var lengthOfLongestSubstring = function(s) {
    if (!s.length) return 0;
    var max = 1, flag = 0
    for(var i = 0; i < s.length; i++) {
        
        var index = s.indexOf(s[i], flag) 
        if (index !== -1 && index < i) flag = index + 1;
        
        max = Math.max(max, i - flag + 1)
    }
    return max
};
```