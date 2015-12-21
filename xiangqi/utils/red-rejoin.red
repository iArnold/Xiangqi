rejoin: func [
    "Reduces and joins a block of values." 
    block [block!] "Values to reduce and join"
][
    if empty? block: reduce block [return block] 
    append either series? first block [copy first block] [
        form first block
    ] next block
]