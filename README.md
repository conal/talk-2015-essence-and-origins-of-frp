## The essence and origins of FRP

Versions:

*   [LambdaJam](lambdajam.com) 2015 (July 15--16) keynote:
    *   [slides](http://conal.net/talks/essence-and-origins-of-frp-lambdajam-2015.pdf)
    *   [Video](https://www.youtube.com/watch?v=j3Q32brCUAI)
*   Related talks, also from Lambda Jam 2015:
    *   [Denotational Design: from meanings to programs](https://github.com/conal/talk-2014-lambdajam-denotational-design)
    *   [A more elegant specification for FRP](https://github.com/conal/talk-2015-more-elegant-frp), previously part of the essence-and-origins talk
*   Preview version from [BayHac](http://bayhac.org/) 2015 (June 12--14):
    *   [slides](http://conal.net/talks/essence-and-origins-of-frp-bayhac-2015.pdf)
    *   [video](http://begriffs.com/posts/2015-07-22-essence-of-frp.html)

### Abstract

Functional Reactive Programming (FRP) is now 20 years old.
Although originally motivated by interactive 3D computer graphics, FRP is a general paradigm for describing dynamic (time-varying) information.
Such information had traditionally been described in software only indirectly, as successive side effects of sequential execution.
In contrast, FRP expressions describe entire evolutions of values over time, representing these evolutions directly as first-class values.
From the start, FRP has been based on two simple and fundamental principles, namely (a) having a precise and simple denotation and (b) continuous time.
The first property, which Peter Landin called "denotative" (and "genuinely functional"), applies across problem domains and ensures a precise, implementation-independent specification, insulated from operational details as found in efficient implementations.
As such, denotative systems can be reasoned about practically and rigorously.
The second property (temporal continuity) is domain-specific and is crucial for simple composability, natural specification of behavior via integration and differentiation, and adaptively efficient implementations.

Over the last few years, something about FRP has generated a lot of interest among programmers, inspiring several so-called "FRP" systems implemented in various programming languages.
Most of these systems, however, lack both of FRP's fundamental properties.
Missing a denotation, they're defined only in vague and/or operational terms (e.g. "graphs" and "update propagation").
Missing continuous time, they fail to provide temporal modularity (sampling-independence and natural temporal transformability), committing prematurely to sampling rates that may turn out to be too low for accuracy or too high for efficiency.
For the same reason, these systems cannot express behaviors as integrals or derivatives and must instead express explicit approximations, leading to cluttered code with poor quality and/or performance.
(Discrete notions of imagery have these same drawbacks, remedied by vector graphics and other continuous models.)

In this talk, I'll share with you the essence of the original (denotative and continuous) FRP.
You'll see the thought processes that led to its design, including the care I took to keep the specification both precise and simple, and hopefully, you'll get a sense of why you might care.
As a more in-depth follow-up, the "Denotational Design" workshop explores how to use denotations to design libraries in general.

### Also related

*   My FRP summaries on StackOverflow:
    *   [What is (functional) reactive programming?](http://stackoverflow.com/questions/1028250/what-is-functional-reactive-programming/1030631#1030631)
    *   [Specification for a Functional Reactive Programming language](http://stackoverflow.com/questions/5875929/specification-for-a-functional-reactive-programming-language#5878525)
    *   [The difference between Reactive and Functional-Reactive programming](http://stackoverflow.com/questions/5385377/the-difference-between-reactive-and-functional-reactive-programming/5386908#5386908)
*   [The Haskell Cast Episode 9 - Conal Elliott on FRP and Denotational Design](https://www.haskellcast.com/episode/009-conal-elliott-on-frp-and-denotational-design).
