I don't understand what you mean by a race condition. A race condition typically occurs when different parallel threads try to access/modify the same shared resource at once. But Dart is a single threaded system.

The only kind of conflicts you may get are perhaps from the various `async` events running in the event loop. Only one event runs at a time. Another event will only run if you yield away your control using `await` (or other equivalent syntaxes). 

Each of the read and write statement is always "atomic" in Dart in the sense that only one event is running at a time. If at all you need to enforce logical transactions that involve blocks of code, just make sure you don't yield away control using `await` when you don't want to. 

---

> The provided callback is immediately called synchronously. It must not return a future (the callback cannot be async), since then it would be unclear when the state was actually being set.
> 
> Calling setState notifies the framework that the internal state of this object has changed in a way that might impact the user interface in this subtree, which causes the framework to schedule a build for this State object. [[1]](#setState)

---

Flutter's SchedulerBinding has four major phases, one of which is `idle` and the rest are related to building and rendering a "frame". [[2]](#vikings)

New events from the event loop are only popped and executed in the `idle` phase.

---


> Flutter uses the event loop to schedule frame callbacks. When Flutter determines that a new frame is needed — due to user interactions, animations, or state changes — it calls methods like scheduleFrame on the WidgetsBinding. This schedules a callback that gets added to Dart’s event loop. [[3]](#3)

---

If you follow the Flutter framework internal code [[4]](#github), you can see that `setState` ultimately only does the work of setting some flags that say to the framwork: "if you are trying to schedule a frame, please do it, cause there are some widgets whose states have changed". 

The importance of this is that, unless these flags show that there is a dirty widget (or some other reason like this), Flutter will not schedule a new frame even if it can. [[2]](#vikings)

---


> The original version of this API was a method called markNeedsBuild, for consistency with RenderObject.markNeedsLayout, RenderObject.markNeedsPaint, et al.
> 
> However, early user testing of the Flutter framework revealed that people would call markNeedsBuild() much more often than necessary. Essentially, people used it like a good luck charm, any time they weren't sure if they needed to call it, they would call it, just in case.
> 
> Naturally, this led to performance issues in applications.
> 
> When the API was changed to take a callback instead, this practice was greatly reduced. One hypothesis is that prompting developers to actually update their state in a callback caused developers to think more carefully about what exactly was being updated, and thus improved their understanding of the appropriate times to call the method.
> 
> In practice, the setState method's implementation is trivial: it calls the provided callback synchronously, then calls Element.markNeedsBuild. [[1]](#setState)

---

So it does NOT matter how many times you call it, where in the function you call it, or the callback that you pass to it, `setState` only does the job of setting the widget as dirty.

So all of these codes are equivalent (among several other variations):

```dart
setState(() {
 futureWait = "$fifteen second wait for both futures completed";
});
futureWaitBool = true;
```

```dart
setState(() {
 futureWait = "$fifteen second wait for both futures completed";
 futureWaitBool = true;
});
```

```dart
futureWait = "$fifteen second wait for both futures completed";
setState(() {
 futureWaitBool = true;
});
```

```dart
futureWait = "$fifteen second wait for both futures completed";
futureWaitBool = true;
setState(() {});
```

---

I tried to find an exact answer to when exactly does the rebuild occurs, but I haven't yet found it.

But I can tell, based on my understanding, that `setState` will not interrupt/stop an ongoing event (such as an `onclick` callback). The frame will be properly scheduled for later through the event loop.

---

### Citations and additional reading
<a id="setState"> 1. https://api.flutter.dev/flutter/widgets/State/setState.html </a>

<a id="vikings"> 2. https://youtu.be/_gIbneld-bw?si=P0YQfBiciReW3OKb </a>

<a id="3"> 3. https://medium.com/@pomis172/understanding-flutter-rendering-pipeline-build-phase-cf7e05aa12f1#:~:text=When%20Flutter%20determines%20that%20a%20new%20frame%20is%20needed%20%E2%80%94%20due%20to%20user%20interactions%2C%20animations%2C%20or%20state%20changes%20%E2%80%94%20it%20calls%20methods%20like%20scheduleFrame%20on%20the%20WidgetsBinding.%20This%20schedules%20a%20callback%20that%20gets%20added%20to%20Dart%E2%80%99s%20event%20loop. </a>

<a id="github"> 4. https://github.com/flutter/flutter </a>