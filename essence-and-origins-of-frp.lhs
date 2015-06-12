%% -*- latex -*-

%% %let atwork = True

% Presentation
\documentclass{beamer}
% \documentclass[handout]{beamer}

%% % Printed, 2-up
%% \documentclass[serif,handout]{beamer}
%% \usepackage{pgfpages}
%% \pgfpagesuselayout{2 on 1}[border shrink=1mm]

%% % Printed, 4-up
%% \documentclass[serif,handout,landscape]{beamer}
%% \usepackage{pgfpages}
%% \pgfpagesuselayout{4 on 1}[border shrink=1mm]

\usefonttheme{serif}

\usepackage{hyperref}
\usepackage{color}

\definecolor{linkColor}{rgb}{0.62,0,0}
\definecolor{partColor}{rgb}{0,0,0.8}

\hypersetup{colorlinks=true,urlcolor=linkColor}

%% \usepackage{beamerthemesplit}

%% % http://www.latex-community.org/forum/viewtopic.php?f=44&t=16603
%% \makeatletter
%% \def\verbatim{\small\@verbatim \frenchspacing\@vobeyspaces \@xverbatim}
%% \makeatother

\usepackage{graphicx}
\usepackage{color}
\DeclareGraphicsExtensions{.pdf,.png,.jpg}

%% \usepackage{wasysym}
\usepackage{mathabx}
\usepackage{setspace}
\usepackage{enumerate}

\useinnertheme[shadow]{rounded}
% \useoutertheme{default}
\useoutertheme{shadow}
\useoutertheme{infolines}
% Suppress navigation arrows
\setbeamertemplate{navigation symbols}{}

\input{macros}

%include polycode.fmt
%include forall.fmt
%include greek.fmt
%include mine.fmt

\title{The essence and origins of FRP}
% \subtitle{\emph{or}\\ How you could have invented \\ Functional Reactive Programming}
\author{\href{http://conal.net}{Conal Elliott}}
% \institute{\href{http://tabula.com/}{Tabula}}
% Abbreviate date/venue to fit in infolines space
\date{June, 2015}
% \date{\emph{Draft of \today}}

\setlength{\itemsep}{2ex}
\setlength{\parskip}{1ex}

% \setlength{\blanklineskip}{1.5ex}

\nc\pitem{\pause \item}

\nc\partframe[1]{\framet{}{\begin{center} \vspace{6ex} {\Huge \textcolor{partColor}{#1}} \end{center}}}
%\nc\partframe[1]{\framet{}{\begin{center} \huge \emph{\textcolor{blue}{#1}} \end{center}}}


%%%%

% \setbeameroption{show notes} % un-comment to see the notes

\setstretch{1.2}

\begin{document}

\rnc\quote[2]{
\begin{center}\begin{minipage}[t]{0.7\textwidth}\begin{center}
\emph{#1}
\end{center}
\begin{flushright}
\vspace{-1.2ex}
- #2\hspace{2ex}~
\end{flushright}
\end{minipage}\end{center}
}
\nc\pquote{\pause\quote}

\frame{\titlepage}


\partframe{What is FRP?}

\framet{FRP's two fundamental properties}{
\begin{itemize}\itemsep2ex
  \item \emph{Continuous} time.
  (Natural \& composable.)
\item Precise, simple denotation.
  (Elegant \& rigorous.)
\end{itemize}
{\parskip 3ex

\pause

Deterministic, continuous ``concurrency''.

Warning: most modern ``FRP'' systems have neither property.

% More aptly, \emph{``Denotative continuous-time programming''} (DCTP).
}
}

\framet{Why continuous \& infinite (vs discrete/finite) time?}{
\pause
\begin{itemize}\itemsep0.3ex
\item Transformation flexibility with simple \& precise semantics
\item Efficiency (adapative)
\item Quality/accuracy
\item Modularity/composability:
  \begin{itemize}
  \item Fewer assumptions, more uses (resolution-independence).
  \item More info available for extraction.
  \item Same benefits as pure, non-strict functional programming.\\
        See \href{http://www.cse.chalmers.se/~rjmh/Papers/whyfp.html}{\emph{Why Functional Programming Matters}}.
  \end{itemize}
\item Integration and differentiation: natural, accurate, efficient.
\item Reconcile differing input sampling rates.
\end{itemize}

\vspace{-1ex}

\pause
Same issues as for space, hence vector graphics.

\pause
\emph{Principle:} Approximations/prunings compose badly, so postpone.

%% \item Strengthen induction hypothesis
}

\framet{Semantics}{

Central abstract type: |Behavior a| --- a ``flow'' of values.
\pause\\[5ex]

Precise \& simple semantics:

> meaning :: Behavior a -> (T -> a)

where |T = R| (reals).
\pause\\[4ex]

Much of API and its specification follows from this one choice.

}

\partframe{Original formulation}

\framet{API}{

{ \small

> time       :: Behavior T
> lift0      :: a -> Behavior a
> lift1      :: (a -> b) -> Behavior a -> Behavior b
> lift2      :: (a -> b -> c) -> Behavior a -> Behavior b -> Behavior c
> timeTrans  :: Behavior a -> Behavior T -> Behavior a
> integral   :: VS a => Behavior a -> T -> Behavior a
> NOTHING ...

> instance Num a => Num (Behavior a) where ...
> ...

}
Reactivity later.

}

\framet{Semantics}{

> meaning time               = \ t -> t
> meaning (lift0 a)          = \ t -> a
> meaning (lift1 f xs)       = \ t -> f (meaning xs t)
> meaning (lift2 f xs ys)    = \ t -> f (meaning xs t) (meaning ys t)
> meaning (timeTrans xs tt)  = \ t -> meaning xs (meaning tt t)

> instance Num a => Num (Behavior a) where
>    fromInteger  = lift0 . fromInteger
>    (+)          = lift2 (+)
>    ...

}

\framet{Semantics}{

> meaning time               = id
> meaning (lift0 a)          = const a
> meaning (lift1 f xs)       = f . meaning xs
> meaning (lift2 f xs ys)    = liftA2 f (meaning xs) (meaning ys)
> meaning (timeTrans xs tt)  = meaning xs . meaning tt

> instance Num a => Num (Behavior a) where
>    fromInteger  = lift0 . fromInteger
>    (+)          = lift2 (+)
>    ...

}

\framet{Events}{

\emph{Secondary} type:

> meaning :: Event a -> [(T,a)]  -- non-decreasing times

> never      :: Event a
> once       :: T -> a -> Event a
> (.|.)      :: Event a -> Event a -> Event a
> (==>)      :: Event a -> (a -> b) -> Event b
> predicate  :: Behavior Bool -> T -> Event ()
> snapshot   :: Event a -> Behavior b -> Event (a,b)

}

\framet{Reactivity}{

\emph{Reactive} behaviors are defined piecewise, via events.\hspace{-3pt}\pause:

% \vspace{2ex}

> switcher :: Behavior a -> Event (Behavior a) -> Behavior a

\pause
Semantics:

> meaning (b0 `switcher` e) t = meaning (last (b0 : before (meaning e) t)) t
> SPACE
> before :: [(T,a)] -> T -> [a]
> before os t  = [a | (ta,a) <- os, ta < t]

\pause \\
\out{
Event occurrences \emph{cannot} be extracted.
(No |changes|/|updates|.)
}
Question: Can occurrences be extracted (``|changes|'')?

}

\partframe{Modernized formulation}

\framet{API}{

Replace several operations with standard abstractions:

> instance Functor Behavior where ...
> instance Applicative Behavior where ...
> instance Monoid a => Monoid (Behavior a) where ...

> instance Functor Event where ...
> instance Monoid a => Monoid (Event a) where ...

Less learning, more leverage.

}

\framet{Semantic instances}{

> instance Functor      ((->) z) where ...
> instance Applicative  ((->) z) where ...
> SPACE
> instance Monoid  a => Monoid  (z -> a) where ...
> instance Num     a => Num     (z -> a) where ...
> ...

\ 

The |Behavior| instances follow in ``precise analogy''.
}

\framet{Homomorphisms}{

A ``homomorphism'' $h$ is a function that preserves (distributes over) an algebraic structure.
For instance, for \texttt{Monoid}:\\[2ex]

> h mempty      == mempty
> h (as <> bs)  == h as <> h bs

\ 

\pause
Some monoid homomorphisms:\\[2ex]

> length' :: [a] -> Sum Int
> length' = Sum . length
> SPACE
> log' :: Product R -> Sum R
> log' = Sum . log . getProduct

\out{
\ 

\pause
\vspace{-5ex}where\vspace{-1ex}

> newtype Sum a = Sum a 
> instance Num a => Monoid (Sum a) where
>   mempty          = Sum 0
>   Sum x <> Sum y  = Sum (x + y)

}

\out{
\vspace{-3ex}
Note that:

> length (as ++ bs)  == length as ++ length bs
> log (a * b)        == log a + log b

}
}

\framet{More homomorphisms}{

|Functor|:

> h (fmap f xs) == fmap f (h xs)

|Applicative|:

> h (pure a)     == pure a
> h (fs <*> xs)  == h fs <*> h xs

|Monad|:

> h (m >>= k) == h m >>= h . k

}

\framet{Specification by semantic homomorphism}{

Specification: |meaning| as homomorphism.
For instance,

> meaning (fmap f as)  == fmap f (meaning as)
> SPACE
> meaning (pure a)     == pure a
> meaning (fs <*> xs)  == meaning fs <*> meaning xs

}

\framet{Semantic instances}{

> instance Monoid a => Monoid (z -> a) where
>   mempty  = \ z -> mempty
>   f <> g  = \ z -> f z <> g z

> instance Functor ((->) z) where
>   fmap g f = g . f

> instance Applicative  ((->) z) where
>  pure a     = \ z -> a
>  ff <*> fx  = \ z -> (ff z) (fx z)

}

\setlength{\fboxsep}{-1.7ex}

\framet{Semantic homomorphisms}{

Put the pieces together:

\begin{center}
\fbox{\begin{minipage}[c]{0.48\textwidth}

>     meaning (pure a)
> ==  pure a
> SPACE
> ==  \ t -> a

\end{minipage}}
\hspace{0.02\textwidth}
\fbox{\begin{minipage}[c]{0.48\textwidth}

>     meaning (fs <*> xs)
> ==  meaning fs <*> meaning xs
> SPACE
> ==  \ t -> (meaning fs t) (meaning xs t)

\end{minipage}}
\end{center}

\vspace{1ex}
Likewise for |Functor|, |Monoid|, |Num|, etc.

\vspace{1.5ex}\pause

Notes:
\begin{itemize}
\item Corresponds exactly to the original FRP denotation.
\item Follows inevitably from semantic homomorphism principle.
\item Laws hold for free (already paid for).
\end{itemize}

}

\framet{Laws for free}{

%% Semantic homomorphisms guarantee class laws. For `Monoid`,

\begin{center}
\fbox{\begin{minipage}[c]{0.4\textwidth}

> meaning mempty    == mempty
> meaning (a <> b)  == meaning a <> meaning b

\end{minipage}}
\begin{minipage}[c]{0.07\textwidth}\begin{center}$\Rightarrow$\end{center}\end{minipage}
\fbox{\begin{minipage}[c]{0.45\textwidth}

> a <> mempty    == a
> mempty <> b    == b
> a <> (b <> c)  == (a <> b) <> c

\end{minipage}}
\end{center}
\vspace{-1ex}
where equality is \emph{semantic}.
\pause
Proofs:
\begin{center}
\fbox{\begin{minipage}[c]{0.3\textwidth}

>     meaning (a <> mempty)
> ==  meaning a <> meaning mempty
> ==  meaning a <> mempty
> ==  meaning a

\end{minipage}}
\fbox{\begin{minipage}[c]{0.3\textwidth}

>     meaning (mempty <> b)
> ==  meaning mempty <> meaning b
> ==  mempty <> meaning b
> ==  meaning b

\end{minipage}}
\fbox{\begin{minipage}[c]{0.39\textwidth}

>     meaning (a <> (b <> c))
> ==  meaning a <> (meaning b <> meaning c)
> ==  (meaning a <> meaning b) <> meaning c
> ==  meaning ((a <> b) <> c)

\end{minipage}}
\end{center}

Works for other classes as well.
}

\framet{Events}{

> newtype Event a = Event (Behavior [a])   -- discretely non-empty
>   deriving (Monoid,Functor)

\ \\

\pause
Derived instances:

> instance Monoid a => Monoid (Event a) where
>   mempty = Event (pure mempty)
>   Event u <> Event v = Event (liftA2 (<>) u v)

> instance Functor Event where
>   fmap f (Event b) = Event (fmap (fmap f) b)

\ \\[3ex]

\pause
Alternatively,

> type Event = Behavior :. []

}

\framet{Conclusion}{

\begin{itemize}\itemsep2ex
 \item Two fundamental properties:\\
   \begin{itemize}\itemsep1ex
     \item Continuous time. (Natural \& composable.)
     \item Precise, simple denotation. (Elegant \& rigorous.)\\[1ex]
   \end{itemize}

   \emph{Warning:} most recent ``FRP'' systems lack both.
 \pitem Semantic homomorphisms:
   \begin{itemize}\itemsep1ex
     \item Mine semantic model for API.
     \item Inevitable API semantics (minimize invention).
     \item Laws hold for free (already paid for).
     \item No abstraction leaks.
     \item Matches original FRP semantics.
     \item Generally useful principle for library design.
   \end{itemize}
\end{itemize}
}

\partframe{History}

\framet{1983--1989 at CMU}{

\begin{itemize}\itemsep2ex
\item
  I went for graphics.
\item
  Did program transformation, FP, type theory.
\item
  Class in denotational semantics.
\end{itemize}

}

\framet{1989 at CMU}{

\begin{itemize}\itemsep2ex
\item
  Kavi Arya's visit
  \begin{itemize}
   \item \emph{Functional animation}
   \item Streams of pictures
   \item Mostly elegant
  \end{itemize}
\item John Reynolds' insight: continuous time.
  Roughly,\\[1.5ex]
{
 \parindent2ex
 \small
``You can think of sequences as functions from the natural numbers.\\
Have you thought about functions from the reals instead?\\
Doing so might help with the awkwardness of interpolation.''
}
\item
  Finished my dissertation anyway.
\end{itemize}

}

\framet{1990--93 at Sun: TBAG}{

\begin{itemize}\itemsep1.5ex
\item
  3D geometry etc as first-class immutable values.
\item
  Optimizing compiler via partial evaluation.
\item
  For animation \& interaction, immutable functions of time.
\item
  Multi-way constraints on time-functions.
  % Off-the-shelf constraint solvers (DeltaBlue \& SkyBlue from UW).
\item
  Differentiation, integration and ODEs specified via |derivative|.
  Adaptive Runge-Kutta-5 solver (fast \& accurate).
\item
  Efficient multi-user distributed execution for free.
\item
  Reactivity via \texttt{assert}/\texttt{retract} (high-level but imperative).
\item
  In Common Lisp, C++, Scheme.
\end{itemize}

}

\framet{1994--1996 at MSR: RBML/ActiveVRML}{

\begin{itemize}\itemsep2ex
\item
  Programming model \& fast implementation for new 3D hardware.
\item
  TBAG + denotative/functional reactivity.
\item
  Add event algebra to behavior algebra.
\item
  Reactivity via behavior-valued events.
\item
  Drop multi-way constraints ``at first''.
\item
  Started in ML as ``RBML''.
\item
  Rebranded to
   ``\href{http://conal.net/papers/ActiveVRML/}{ActiveVRML}'', then
   ``\href{http://www.sworks.com/keng/da.html}{DirectAnimation}''.
\end{itemize}
}

\framet{1996--1999 at MSR: RBMH/Fran}{

\begin{itemize}\itemsep2ex
\item
  Found Haskell: reborn as ``RBMH'' (research vehicle).
\item
  Very fast implementation \href{http://conal.net/papers/padl99/}{via sprite engine}.
\item
  John Hughes suggested using |Arrow|.
\end{itemize}

}

\framet{2000 at MSR: first try at push-based implementation}{

\begin{itemize}\parskip2ex
\item Algebra of imperative event listeners.
\item Challenges:
 \begin{itemize}\itemsep2ex
  \item
    Garbage collection \& dependency reversal.
  \item
    Determinacy of timing \& simultaneity.
  \item
    I doubt anyone has gotten correct.
 \end{itemize}
\end{itemize}

}

\framet{2009: \href{http://conal.net/papers/push-pull-frp/}{Push-pull FRP}}{

\begin{itemize}\itemsep1.5ex
\item Minimal computation, low latency, \emph{provably correct}.
\item Push for reactivity and pull for continuous phases.
\item ``Push'' is really blocked pull.
\item
  Modernized API:
  \begin{itemize}
  \item Standard abstractions.
  \item Semantics as homomorphisms.
  \item Laws for free.
  \end{itemize}
\item
  Reactive normal form, via equational properties (denotation!).
\item
  Uses |lub| (basis of PL semantics).
\item
  Implementation subtleties \& GHC RTS bugs. Didn't quite work.
\end{itemize}

}

\framet{1997--2014: Paul Hudak / Yale}{

\begin{minipage}[c]{0.6\textwidth}
\begin{itemize}\itemsep2ex
\item Paul Hudak visited MSR in 1996 or so and saw RBMH.
\item Encouraged me to publish and suggested collaboration.
\item Proposed names ``Fran'' \& ``FRP''.
\item Many FRP-based papers and theses, drawing much attention.
\end{itemize}
\end{minipage}
\begin{minipage}[c]{1.8in}
\begin{center}
\wpicture{1.7in}{paul-hudak}\\
{\small July 15, 1952 -- April 29, 2015}
\end{center}
\end{minipage}
}

\out{

\framet{2012--now: ``FRP'' diffusion}{

\begin{itemize}
\item ``FRP'' systems appear that lack both fundamental properties:
  \begin{itemize}
   \item Elm
   \item Bacon
  \end{itemize}
\end{itemize}

}

}

\end{document}
