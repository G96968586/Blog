---
title: 'LeetCode Questions: Add Two Numbers'
date: 2018-06-04 23:29:46
categories: LeetCode
tags: LeetCode
---

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.
You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example

```
Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
Explanation: 342 + 465 = 807.
```
<!-- more -->
My answer:

```
/**
 * Definition for singly-linked list.
 * function ListNode(val) {
 *     this.val = val;
 *     this.next = null;
 * }
 */
/**
 * @param {ListNode} l1
 * @param {ListNode} l2
 * @return {ListNode}
 */
var addTwoNumbers = function(l1, l2) {
  // 进位
  let carry = false;
  // 先取第一个节点
  let l1Node = l1;
  let l2Node = l2;
  // 临时节点
  let tmpNode;
  while(l1Node && l2Node || carry) {
      let sum = 0;
      if (l1Node) {
          sum += l1Node.val;
      }
      if (l2Node) {
          sum += l2Node.val;
      }
      // 此次运算是否需要进位加 1
      if (carry) {
          sum += 1;
          // 复位
          carry = false;
      }
      // 判断是否进位
      if (sum > 9) {
          sum -= 10;   
          // 告知下一次循环需要进位
          carry = true;
      }
      if (l1Node) {
        // 存放最后一个 l1Node 非空节点
        tmpNode = l1Node;
        l1Node.val = sum;
      } else {
        // 如果 l1Node 为空，则拿它的前一个节点（这里是 tmpNode）的 next 拼接上新的节点
        tmpNode.next = new ListNode(sum);
        tmpNode = tmpNode.next;
      }
      // 取链表下一个节点
      l1Node = l1Node && l1Node.next;
      l2Node = l2Node && l2Node.next;
  }
  // 如果较长链表 是 l2，则链接在 l1 的末端
  if (l2Node) {
    tmpNode.next = l2Node;
  }
    return l1;
};
```

![](https://gw.alicdn.com/tfs/TB1fLSZvTtYBeNjy1XdXXXXyVXa-2332-792.png)


官方答案，学习其思路，很多地方可以借鉴（相信自己的思维可以越来越好）～

```
public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    ListNode dummyHead = new ListNode(0);
    ListNode p = l1, q = l2, curr = dummyHead;
    int carry = 0;
    while (p != null || q != null) {
        int x = (p != null) ? p.val : 0;
        int y = (q != null) ? q.val : 0;
        int sum = carry + x + y;
        carry = sum / 10;
        curr.next = new ListNode(sum % 10);
        curr = curr.next;
        if (p != null) p = p.next;
        if (q != null) q = q.next;
    }
    if (carry > 0) {
        curr.next = new ListNode(carry);
    }
    return dummyHead.next;
}
```
