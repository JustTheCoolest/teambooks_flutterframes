class Solution:
    def longestConsecutive(self, nums):
       nums_set = set(nums)
       c=0
       for num_b in nums:
           if num_b+1 in nums_set:
               c=c+1
        return c

nums =  [100, 4, 200, 1, 3, 2]
s = Solution()
d = s.longestConsecutive(nums)
print(d)