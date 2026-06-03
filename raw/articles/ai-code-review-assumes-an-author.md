# Code review assumes an author

> Posted on: June 1, 2026
> Source: https://blog.raed.dev/posts/ai-code-review/

Code review only works if someone accountable for the pull request understands the code well enough to explain it and operate it.

That was never perfectly true. People have always copied snippets they half-understood and inherited code they didn’t write. Large systems have always contained more context than any one person could hold. But the pull request still rested on a basic assumption: a human was close enough to the work to be questioned about it.

You asked why something was implemented the way it was, and the answer came from somewhere. Maybe a constraint the author was coding around, maybe an informal discussion with a teammate or something. Review caught what the author missed, but it started from the author having a model of the change in their head.

That assumption is starting to break, and agentic development changes the failure mode. Getting a model to write code is no longer the hard part. The shift is that a system can now iterate on its own output and produce a pull-request-shaped artifact before any human understands what it changed or how it breaks.

A lot of delivered code now arrives fluent on the surface, plausible line by line, with no one behind it who can explain the choices. The author is a proxy. The diff is real, the tests pass, there’s a human name on the pull request, and none of that means the reasoning behind it lives in that human’s head.

When you ask why, the answer is sometimes just: “that was the output I accepted.” That’s a different kind of authorship. Or worse, they pipe the question straight into another model, ensuring no thinking is done during the process.

## The bottleneck

The usual complaint is that review becomes a bottleneck once generating code is cheap. That’s true, and it’s the least interesting part of what’s happening. The more important question is what the bottleneck is now being asked to do.

Review was designed to challenge work that someone already (*somewhat*) understood. We’re now using it as the place where understanding is supposed to appear for the first time, which is a much heavier job.

Pointing another model at the review helps, but only up to a point. It catches style issues, missing null checks, the obvious security footguns. That’s useful, and worth automating wherever you can. But in a large system, a reviewer’s real value is knowing what the diff doesn’t say.

A service three repositories away depends on this retry behavior. A nightly job nobody has opened in a year reads that field. This migration is safe for new customers and dangerous for old ones. The code looks redundant because someone removed the obvious abstraction after an incident, and that test passes because the fixture is wrong.

Some of that context can be retrieved, and more of it will be over time. Models will read more files and crawl further across repositories and logs. That’ll make review better. It won’t remove the underlying problem.

The hardest context usually isn’t in the codebase at all. It lives in incident history and team boundaries, and in the memory, written down nowhere, of why the obvious solution got rejected three years ago. A model can retrieve artifacts. It can’t be accountable for the judgment that ties them together.

## Is code review doomed?

The first adaptation might be embarrassingly simple. An AI-assisted pull request isn’t ready for review until the human submitting it can explain the intent, the invariants it touches, and the evidence that it’s safe. Producing that explanation is what forces ownership back into the process; the document it produces barely matters.

If the author can’t explain the change, the pull request isn’t ready. It’s still just generated output.

This doesn’t solve the whole problem. It doesn’t tell you how to review a huge agent-produced change, or how to assign ownership. I’d be suspicious of anyone selling a full replacement this early.

But I’m fairly sure of one thing: the pull request, as we practice it today, is a pre-LLM artifact. It encodes assumptions about authorship, ownership and understanding that mostly held when a human typed the code, and hold a lot less reliably when a model did.

We kept the ritual and changed what it rests on without admitting it.

Everyone’s working on reviewing AI-generated code faster and with even more AI. The harder question is what review even means when the person asking for approval may not understand the code underneath it.
