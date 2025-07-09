"race condition" require paralellism - dart is single thread - no async allowed inside setState - since async await is asynchronous (not parallel), all reads and writes are always atomic 

if logical semaphores - position of await

ask clarity on why race condition

setState executes synchronously immediately after calling it 
[citation - documentation]

setState is the same no matter how, when and how many times you call it
[examples]

[desing discussion and citation]

setState marks the frame as dirty

does not actually do any real work related to frame scheduling, it only flips the flag

SchedulerBinding - 4 phases - idle phase keeps executing the event loop - as long as there is no need to rebuild  [citation - youtube vikings] - the other three phases relate to the building process [citation - article on detecting whether we are currently building]

my understanding - current function stack is finished fully - onclick example - no matter how many times we update setState, no problem - values used are always the latest values

frame building add to queue - [webpage citation]