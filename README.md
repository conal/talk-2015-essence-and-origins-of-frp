## The essence and origins of FRP

A keynote talk at LambdaJam 2015 (July 15--16).
I might preview the talk at BayHac 2015 (June 12--14).

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
