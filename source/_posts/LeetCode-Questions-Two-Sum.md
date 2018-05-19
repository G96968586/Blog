---
title: 'LeetCode Questions: Two Sum'
date: 2018-05-19 13:41:35
categories: LeetCode
tags: LeetCode
---

![img](https://gw.alipayobjects.com/zos/skylark/53af2bf7-990e-4ae7-9e4e-d63ff79cba28/2018/png/4feccaef-8798-47a9-977a-c383315bf53e.png)

<!-- more -->

My answer: 

```
/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
var twoSum = function(nums, target) {
    // my answer
    var result = [];
    var length = nums.length;
    if (length > 0) {
        for (var i = 0; i < length; i++) {
            var tmp = target - nums[i];
            var tmpIndex = nums.lastIndexOf(tmp);
            if (tmpIndex > 0) {
                result = [i, tmpIndex];
                break;
            }
        }
    }
    return result;
};

```

![img](https://gw.alipayobjects.com/zos/skylark/488e5f55-0272-4a56-bf46-6b6d6bed9327/2018/png/40c9eae9-4d97-4276-a13b-64744fd20025.png)

You can see, my runtime is 207ms, see another best answer:

![img](https://gw.alipayobjects.com/zos/skylark/7156a3f7-7caa-4a90-905c-2fc8c4a6e59b/2018/png/1d87cfb2-3c31-46ac-bfb0-74fba0d20a93.png)