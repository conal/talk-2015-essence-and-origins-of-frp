# How you could have invented functional reactive programming

[*A Brief Introduction to ActiveVRML*]: http://conal.net/papers/ActiveVRML/ "Tech report (1996)"

[*Functional Reactive Animation*]: http://conal.net/papers/icfp97/ "paper"

[*Push-pull functional reactive programming*]: http://conal.net/papers/push-pull-frp/ "Paper"

[*From Functional Animation to Sprite-Based Display*]: http://conal.net/papers/padl99/ "paper by Conal Elliott (1999)"

[*Why Functional Programming Matters*]: http://www.cse.chalmers.se/~rjmh/Papers/whyfp.html "Paper by John Hughes (1984)"

These notes are for a talk at BayHac 2015 (June 12--14) and keynote at LambdaJam 2015 (July 15--16).

## Outline

### History

*   1983-1989 at CMU:
    *   Went for graphics.
    *   Did FP, program transformation, type theory, HOU.
*   1989 at CMU:
    *   Kavi Arya's "functional animation" and John Reynolds insight.
    *   Finished my dissertation anyway.
*   1990-93 at Sun: TBAG
    *   3D geometry etc as first-class immutable values.
    *   In Common Lisp, C++, Scheme.
    *   Optimizing compiler to rendering code via partial evaluation & fusion.
    *   For animation & interaction, immutable functions of time to geometry etc.
    *   Multi-way constraints, with time-functions for variables.
        Off-the-shelf constraint solvers (DeltaBlue & SkyBlue from UW).
    *   Differentiation, integration and ODEs specified via `deriv`.
        Adaptive fifth-order Runge-Kutta ODE solver for speed & accuracy.
    *   Efficient multi-user distributed execution for free.
    *   Reactivity via constraint `assert`/`retract` (high-level but imperative).
    *   C++ version: simpler (no compilation).
*   1994-1999 at Microsoft Research: RBML/ActiveVRML, RBMH/Fran
    *   Design programming model and fast implementation for new 3D architecture (Talisman).
    *   Research goal: TBAG + denotative/functional reactivity.
    *   Drop constraints "at first".
    *   Add event algebra to behavior algebra.
    *   Reactivity via behavior-valued events.
    *   Started in ML as "RBML".
    *   Rebranded to "[ActiveVRML][*A Brief Introduction to ActiveVRML*]", then "[DirectAnimation](http://www.sworks.com/keng/da.html)".
    *   Found Haskell: reborn as RBMH (research vehicle).
    *   Paul Hudak (RIP) suggested names "Fran" and then "FRP".
    *   Very fast implementation via sprite engine. ([paper][*From Functional Animation to Sprite-Based Display*])
*   2000 at MSR: attempted first push-based implementation
    *   Garbage collection problems.
    *   Determinacy of timing & simultaneity.
    *   Algebra of event listeners.
    *   I don't think *anyone* has gotten correct.
*   2009: [Push-pull FRP][*Push-pull functional reactive programming*]
    *   Modernized API:
        *   Standard abstractions.
        *   Semantics as homomorphisms.
        *   Laws for free.
    *   Another attempt at push for reactivity and pull for continuous phases.
    *   Reactive normal form, via equational properties (denotation!).
    *   "Push" is really blocked pull.
    *   Uses LUB (basis of PL semantics).
    *   Implementation subtleties & GHC RTS bugs.
        Didn't quite work.

## What is FRP?

Two essential properties:

*   *Continuous* time! (Natural & composable.)
*   Denotational design. (Elegant & rigorous.)

Deterministic, continuous "concurrency".

More aptly, *"Denotative continuous-time programming"* (DCTP).

Warning: many modern "FRP" systems have neither property.

## Why continuous & infinite (vs discrete/finite) time?

*From LambdaJam 2014 talk.*

## Semantics

Central abstract type: `Behavior a`.
A "flow" of values.

Precise & simple semantics:

> meaning :: Behavior a -> (R -> a)

API and its specification follows mostly from this one choice.

## API

Note *semantic* instances:

> instance Functor     ((->) t) where ...
> instance Applicative ((->) t) where ...
> instance Monad       ((->) t) where ...
>
> instance Monoid      ((->) t) where ...
> instance Num         ((->) t) where ...
> ...

API follows in "precise analogy" from semantics.

## Homomorphisms

A "homomorphism" $h$ is a function that preserves an algebraic structure.
For instance, for `Monoid`:

> h mempty == mempty
> h (as <> bs) == h as <> h bs

For instance,

> lenS :: [a] -> Sum Int
> lenS = Sum . length

> log' :: Product R -> Sum R
> log' = Sum . log . getProduct

Homomorphism proofs:

>   lenS mempty
> == Sum (length mempty)
> == Sum (length [])
> == Sum 0
> == mempty

>   lenS (as <> bs)
> == Sum (length (as <> bs))
> == Sum (length (as ++ bs))
> == Sum (length as + length bs)
> == Sum (length as) <> Sum (length bs)

## Specification by semantic homomorphism

Functor homomorphism (naturality):

> h (f <$> as) == f <$> h as

i.e.,

> h . fmap f == fmap f . h

## Events

> meaning :: Event a -> [(R,a)]

Stylistic tweak for homomorphisms:

> meaning :: Event a -> ([] :. (,) R)

or

> type Event = Behavior :. []  -- discretely non-empty

## Reactivity

Events generate new behavior phases:

> switcher ::  Behavior a -> Event (Behavior a) -> Behavior a

----

## Misc

*   There are two essential ideas---one domain-independent, and one domain-specific:
    *   Build on a precise and simple *denotation*:
        *   Well-specified, independent of an implementation.
        *   Enables practical, dependable reasoning.
    *   Continuous time (resolution-independence):
        *   Naturalness
        *   Transformation flexibility with simple & precise semantics
        *   Modularity/composability, as with pure, non-strict functional programming.
            See [*Why Functional Programming Matters*].
        *   Efficiency (adapative)
        *   Quality/accuracy
        *   Integration and differentiation: natural, accurate, efficient.
        *   Reconcile differing input sampling rates.

    Warning: most modern "FRP" systems have neither property.
*   Origins of functional reactive programming:
    *   While a grad student at Carnegie Mellon, I had a class in *denotational semantics*, as developed by Chris Strachey and Dana Scott in the late 1960s.
        *   The idea of denotational semantics is to define a mathematical type ("domain") of meanings (denotations) of utterances in a language, and then define the language's meaning as a mapping from the (abstract) syntax to semantics/meanings.
            *   The mapping must be *compositional*, i.e., the meaning of an expression depends only on the meaning of its sub-expressions ("structural induction").
    *   In 1988 or 1989, when nearing completion at CMU, Kavi Arya gave a talk on "functional animation", as streams of pictures.
        Fairly elegant for some operations.
        At the end of Kavi's talk, [John Reynolds](http://www.cs.cmu.edu/~jcr/) offered a remark, roughly as follows:

         >
        You can think of sequences as functions from the natural numbers.
        Have you thought about functions from the reals instead?
        Doing so might help with the awkwardness of interpolation.

        I knew at once I'd heard a wonderful idea, so I went back to my office, wrote it down, and promised myself that I wouldn't think about Kavi's work and John's insight until my dissertation was done.
        Otherwise, I might never have finished.
        See [*Early inspirations and new directions in functional reactive programming*](http://conal.net/blog/posts/early-inspirations-and-new-directions-in-functional-reactive-programming/).
    *   About two years later, at Sun Microsystems, I started working on functional animation in the [TBAG](http://conal.net/tbag/) system (first in Lisp), modeling animation as functions of *continuous time*, as John Reynolds had suggested.
    *   In 1994, I moved to Microsoft Research and extended the TBAG ideas to include functional reactivity, forming what came to be called "functional reactive programming" (FRP), first as ActiveVRML and then Fran.
    *   Instead of a *language*, I applied DS to an API.
        *   Much more useful, since we define many more APIs than languages.
        *   Assign a semantic domain to every type.
        *   Define the meaning of each primitive as a function of the meanings of its arguments.
        *   Complements the host language's semantics.
    *   I had designed the "reactive behavior modeling" library to use with ML, but in 1995, I found Haskell and realized that it was a better fit.
    *   In 1995 or 1996, I was working with an implementation in Haskell, when Paul Hudak (RIP) visited.
        I showed him my implementation, about which he was quite enthusiastic.
        He suggested that we write a paper together, and that we rename the system "Fran" for "functional reactive animation".
        Later, he suggested "functional reactive programming", since "animation" could easily be understood as about visual animation only.

----        

*   In the dozens of variations on FRP I've played with over the last 20 years, John's refinement of Kavi's idea has always been the heart of the matter for me.

----

