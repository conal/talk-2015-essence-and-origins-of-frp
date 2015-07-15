%% -*- latex -*-

%% %let atwork = True

% Presentation
\documentclass{beamer}
%\documentclass[handout]{beamer}

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

% \definecolor{linkColor}{rgb}{0.62,0,0}
\definecolor{linkColor}{rgb}{0,0.42,0.3}
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
\usepackage{tikzsymbols}

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
\subtitle{\emph{or}\\[1.5ex] How you could have invented \\ Functional Reactive Programming}
\author{\href{http://conal.net}{Conal Elliott}}
% \institute{\href{http://tabula.com/}{Tabula}}
% Abbreviate date/venue to fit in infolines space
% \date{June 2015 / BayHac}
\date{LambdaJam 2015}
% \date{\emph{Draft of \today}}

\setlength{\itemsep}{2ex}
\setlength{\parskip}{1ex}

% \setlength{\blanklineskip}{1.5ex}


%%%%

% \setbeameroption{show notes} % un-comment to see the notes

\setstretch{1.2}

\begin{document}

\frame{\titlepage}
\partframe{What is FRP?}

\framet{FRP's two fundamental properties}{
\begin{itemize}\itemsep3ex
\item Precise, simple denotation.
  (Elegant \& rigorous.)
  \item \emph{Continuous} time.
  (Natural \& composable.)
\end{itemize}
\pause
{
\parskip 3ex
\vspace{4ex}

Deterministic, continuous ``concurrency''.

\pause\vspace{4ex}

Warning: most modern ``FRP'' systems have neither property. {\Large \dSadey}

% More aptly, \emph{``Denotative continuous-time programming''} (DCTP).
% \vspace{4.3ex}
\ 
}
}

\framet{FRP's two fundamental properties}{
\begin{itemize}\itemsep3ex
\item Precise, simple denotation.
  (Elegant \& rigorous.)
  \item \emph{Continuous} time.
  (Natural \& composable.)
\end{itemize}
%\pause

\vspace{2.5ex}

FRP \emph{is not} about:
\pause
\begin{itemize}\itemsep1.2ex
\item graphs,
\item updates and propagation,
\item streams,
\item doing % (operational)
\end{itemize}

}

\framet{Why (precise \& simple) denotation?}{
\pause
\begin{itemize}\itemsep2ex
\item
  Separates specification from implementation.
  % Defines intent, independent of implementation and without handwaving.
\item \emph{Simple} so that we \emph{can} reach conclusions.
\item \emph{Precise} so that our conclusions will be \emph{true}.
\item Denotations have elegant, functional-friendly style.
\end{itemize}

\pause\hspace{2ex}

An API is a language for communicating about a domain.

It helps to (really) understand what we're talking about.

%% \quote{The single biggest problem with communication is the illusion that it has occurred.}{George Bernard Shaw}

}

\framet{Why continuous \& infinite (vs discrete/finite) time?}{
\pause
Same benefits as for space (vector graphics):
%\\ \hspace{6ex} \ldots and for pure, non-strict functional programming.
\pause
\begin{itemize}\itemsep0.3ex
\item Transformation flexibility with simple \& precise semantics.
\item Modularity/reusability/composability:
  \begin{itemize}
  \item Fewer assumptions, more uses (resolution-independence).
  \item More info available for extraction.
  \end{itemize}
\item Integration and differentiation: natural, accurate, efficient.
% \item Simplicity: eliminate non-essential details.
\pause
\item Quality/accuracy.
\item Efficiency (adapative).
\item Reconcile differing input sampling rates.
\end{itemize}
\pause
% \fbox{\emph{Principle:} Approximations/prunings compose badly, so postpone.}
\vspace{1ex}
{\color{blue}
\fbox{\normalcolor\emph{Principle:} Approximations/prunings compose badly, so postpone.}
}

See \href{http://www.cse.chalmers.se/~rjmh/Papers/whyfp.html}{\emph{Why~Functional~Programming~Matters}}.
}

\framet{Semantics}{

Central abstract type: |Behavior a| --- a ``flow'' of values.
\pause\\[5ex]

Precise \& simple semantics:

> meaning :: Behavior a -> (T -> a)

where |T = R| (reals).
\pause\\[4ex]

Much of API and its specification can follow from this one choice.
%% \\Described in the \emph{Denotational Design} teaser.
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
> predicate  :: Behavior Bool -> Event ()
> snapshot   :: Event a -> Behavior b -> Event (a,b)

\\[2ex]
\emph{Exercise:} define semantics of these operations.
}

\framet{Reactivity}{

\emph{Reactive} behaviors are defined piecewise, via events.\hspace{-3pt}\pause:

% \vspace{2ex}

> switcher :: Behavior a -> Event (Behavior a) -> Behavior a

\pause
Semantics:

> meaning (b0 `switcher` e) t = meaning (last (b0 : before t (meaning e))) t
> SPACE
> before :: T -> [(T,a)] -> [a]
> before t os  = [a | (ta,a) <- os, ta < t]

Important: |ta < t|, rather than |ta <= t|.

\out{
\pause \\
Event occurrences \emph{cannot} be extracted.
(No |changes|/|updates|.)
}
% \pause \\ Question: Can occurrences be extracted (``|changes|'')?
}

\partframe{A more elegant specification \\[1.5ex] for FRP (teaser)}

\framet{API}{

Replace operations with standard abstractions where possible:

> instance Functor Behavior where ...
> instance Applicative Behavior where ...
> instance Monoid a => Monoid (Behavior a) where ...
> SPACE
> instance Functor Event where ...
> instance Monoid a => Monoid (Event a) where ...

Why?\pause
\begin{itemize}\itemsep1.5ex
\item Less learning, more leverage.
\item Specifications and laws for free.
\end{itemize}

}

\setlength{\fboxsep}{-1.7ex}

\framet{Specifications for free}{

The \emph{instance's meaning} follows the \emph{meaning's instance}:
\begin{center}
\fbox{\begin{minipage}[c]{0.55\textwidth}

> meaning (fmap f as)  == fmap f (meaning as)
> SPACE
> meaning (pure a)     == pure a
> meaning (fs <*> xs)  == meaning fs <*> meaning xs
> SPACE
> mu mempty            == mempty
> mu (top <> bot)      == mu top <> mu bot

\end{minipage}}
\end{center}
% So |meaning| is a homomorphism (distributes over class operations).
\pause
%Notes:
\begin{itemize}
\item Corresponds exactly to the original FRP denotation.
\item Follows inevitably from a domain-independent principle.
\item Laws hold for free\out{ (already paid for)}.
%\item Details tomorrow.
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
  {\parskip1ex
  Kavi Arya's visit:
  \begin{itemize}\parskip1ex
   \item \emph{Functional animation}
   \item Streams of pictures
   \item Elegant\pause, mostly
  \end{itemize}
  }
\item John Reynolds's insightful remark:\\[1.5ex]
{
 \parindent2ex
 \small
``You can think of streams as functions from the natural numbers.\\
\pause Have you thought about functions from the \emph{reals} instead?\\
Doing so might help with the awkwardness of interpolation.''
}
\\[1.5ex] \emph{Continuous time!}
\pitem
  I finished my dissertation anyway.
\end{itemize}

}

\framet{1990--93 at Sun: \href{http://conal.net/tbag/}{TBAG}}{

\begin{itemize}\itemsep1.2ex
\item 3D geometry etc as first-class immutable values.
\item Animation as immutable functions of continuous time.
\pause
\item Multi-way constraints on time-functions.
      \\Off-the-shelf constraint solvers (DeltaBlue \& SkyBlue from UW).
\item Differentiation, integration and ODEs specified via |derivative|.
      \\Adaptive Runge-Kutta-5 solver (fast \& accurate).
\item Reactivity via \texttt{assert}/\texttt{retract} (high-level but imperative).
\pause
\item Optimizing compiler via partial evaluation.
\item In Common Lisp, C++, Scheme.
\item Efficient multi-user distributed execution for free.
\end{itemize}

}

\framet{1994--1996 at Microsoft Research: RBML/ActiveVRML}{

\begin{itemize}\itemsep2ex
\item Programming model \& fast implementation for new 3D hardware.
\item TBAG + denotative/functional reactivity.
\pause
\item Add event algebra to behavior algebra.
\item Reactivity via behavior-valued events.
\item Drop multi-way constraints ``at first''.
\pause
\item Started in ML as ``RBML''.
\item Rebranded to
 ``\href{http://conal.net/papers/ActiveVRML/}{ActiveVRML}'', then
 ``\href{http://www.sworks.com/keng/da.html}{DirectAnimation}''.
\end{itemize}
}

\framet{1995--1999 at MSR: RBMH/Fran}{

\begin{itemize}\itemsep2ex
\item
  Found Haskell: reborn as ``RBMH'' (research vehicle).
\item
  Very fast implementation \href{http://conal.net/papers/padl99/}{via sprite engine}.
\item
  John Hughes suggested using |Arrow|.
\end{itemize}

}

\framet{1999 at MSR: \href{http://conal.net/papers/new-fran-draft.pdf}{first try} at push-based implementation}{

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
  More elegant API:
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

\framet{1996--2014: Paul Hudak / Yale}{

\begin{minipage}[c]{0.6\textwidth}
\begin{itemize}\itemsep2ex
\item Paul Hudak visited MSR in 1996 or so and saw RBMH.
\item Encouraged publishing, and suggested collaboration.
\item Proposed names ``Fran'' \& ``FRP''.
\item \emph{Many} FRP-based papers and theses.
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

\partframe{Questions}

\framet{}{
\begin{center}
\Large
``But computers are discrete, ...''
\end{center}
}

%\framet{}{}

\partframe{A more elegant specification \\[1.5ex] for FRP}

\framet{API}{

Replace several operations with standard abstractions:

> instance Functor Behavior where ...
> instance Applicative Behavior where ...
> instance Monoid a => Monoid (Behavior a) where ...
> SPACE
> instance Functor Event where ...
> instance Monoid a => Monoid (Event a) where ...

Why?\pause
\begin{itemize}
\item Less learning, more leverage.
\item Specifications and laws for free.

\end{itemize}

}

\framet{Semantic instances}{

> instance Functor      ((->) z) where ...
> instance Applicative  ((->) z) where ...
> SPACE
> instance Monoid  a => Monoid  (z -> a) where ...
> instance Num     a => Num     (z -> a) where ...
> ...

\ 

The |Behavior| instances follow in ``precise analogy'' to denotation.
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

\framet{More homomorphism properties}{

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
     \item Precise, simple denotation. (Elegant \& rigorous.)
     \item Continuous time. (Natural \& composable.)
     \\[1ex]
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

\end{document}
