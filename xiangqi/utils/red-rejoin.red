Red [ "Finally also added to Reds repository in commit 5626 on 6 july 2016"
]

rejoin: function [ "Reduces and joins a block of values." 
    block [block!] "Values to reduce and join"
][
    if empty? block: reduce block [return block] 
    append either series? first block [copy first block] [
        form first block
    ] next block
]
