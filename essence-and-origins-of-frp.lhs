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
% \date{June, 2015}
\date{\emph{Draft of \today}}

\setlength{\itemsep}{2ex}
\setlength{\parskip}{1ex}

% \setlength{\blanklineskip}{1.5ex}

\nc\pitem{\pause \item}

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


\framet{What is FRP?}{

\pause

Two fundamental properties:
\begin{itemize}
  \item \emph{Continuous} time!
  (Natural \& composable.)
\item Denotational design.
  (Elegant \& rigorous.)
\end{itemize}
{\parskip 3ex

\pause

Deterministic, continuous ``concurrency''.

Warning: most modern ``FRP'' systems have neither property.

More aptly, \emph{``Denotative continuous-time programming''} (DCTP).
}
}

\framet{Why continuous \& infinite (vs discrete/finite) time?}{
\pause
\begin{itemize}\itemsep0.5ex
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

\pause
Same issues as space, hence vector graphics.

\pause
Principle: approximations/prunings compose badly, so postpone.

%% \item Strengthen induction hypothesis
}

\framet{Semantics}{

Central abstract type: |Behavior a|. A ``flow'' of values.
\pause\\[5ex]

Precise \& simple semantics:

> meaning :: Behavior a -> (R -> a)

\pause\\[4ex]
API and its specification follows mostly from this one choice.

}

\framet{}{

\begin{center}
\vspace{6ex}
{\Huge Original presentation}
\end{center}

}

\framet{API}{

{ \small

> time       :: Behavior R
> lift0      :: a -> Behavior a
> lift1      :: (a -> b) -> Behavior a -> Behavior b
> lift2      :: (a -> b -> c) -> Behavior a -> Behavior b -> Behavior c
> timeTrans  :: Behavior a -> Behavior R -> Behavior a
> integral   :: VS a => Behavior a -> R -> Behavior a
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

\framet{Events}{

\emph{Secondary} type:

> meaning :: Event a -> [(R,a)]  -- non-decreasing times

> never      :: Event a
> once       :: R -> a -> Event a
> (.|.)      :: Event a -> Event a -> Event a
> (==>)      :: Event a -> (a -> b) -> Event b
> predicate  :: Behavior Bool -> Time -> Event ()
> snapshot   :: Event a -> Behavior b -> Event (a,b)

}

\framet{Reactivity}{

\emph{Reactive} behaviors are defined piecewise, via events.\hspace{-3pt}\pause:

\vspace{4ex}

> switcher :: Behavior a -> Event (Behavior a) -> Behavior a

\pause
\\[4ex]
\out{
Event occurrences \emph{cannot} be extracted.
(No |changes|/|updates|.)
}
Question: Can occurrences be extracted (``|changes|'')?

}

\framet{}{

\begin{center}
\vspace{6ex}
{\Huge Modernized presentation}
\end{center}

}

\framet{API}{

Replace several operations with standard abstractions:

> instance Functor Behavior
> instance Applicative Behavior
> instance Monoid a => Monoid (Behavior a)

> instance Functor Event
> instance Monoid a => Monoid (Event a)

}

\framet{Semantics}{

Consider \emph{semantic} instances:

> instance Functor      ((->) t) where ...
> instance Applicative  ((->) t) where ...
>
> instance Monoid       ((->) t) where ...
> instance Num          ((->) t) where ...
> ...

The instances follow in ``precise analogy'' from semantics.
}

\framet{Homomorphisms}{

A ``homomorphism'' $h$ is a function that preserves an algebraic structure.
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

> h (fmap f im) == fmap f (h im)

|Applicative|:

> h (pure a)       == pure a
> h (imf <*> imx)  == h imf <*> h imx

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
>   f <> g = \ z -> f z <> g z

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

Note:
\begin{itemize}
\item Corresponds exactly to the original FRP denotation.
\item Follows inevitably from semantic homomorphism principle.
\end{itemize}

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

\ \\[3ex]

\pause
Alternatively,

> type Event = Behavior :. []

}

\framet{Conclusions}{

\begin{itemize}
 \item FRP's two fundamental properties:
   \begin{itemize}
     \item Continuous time! (Natural \& composable.)
     \item Denotational design. (Elegant \& rigorous.)
   \end{itemize}\vspace{3ex}
 \item Semantic homomorphisms:
   \begin{itemize}
     \item Mine semantic model for API.
     \item API semantics inevitable from homomorphisms.
     \item Laws hold for free (already paid for).
     \item No abstraction leaks.
     \item Matches original FRP semantics.
     \item Generally useful principle for library design.
   \end{itemize}
\end{itemize}
}

\framet{}{
\begin{center}
\vspace{6ex}
{\Huge History}
\end{center}
}

\framet{1983--1989 at CMU}{

\begin{itemize}\parskip2ex
\item
  Went for graphics.
\item
  Did FP, program transformation, type theory.
\end{itemize}

}

\framet{1989 at CMU}{

\begin{itemize}\parskip2ex
\item
  Kavi Arya's visit
  \begin{itemize}
   \item ``Functional animation'':
   \item Functional streams of pictures
  \end{itemize}
\item John Reynolds' insight: continuous time.
  Roughly,\\[2ex]
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

\begin{itemize}\parskip1ex
\item
  3D geometry etc as first-class immutable values.
\item
  Optimizing compiler via partial evaluation \& fusion.
\item
  For animation \& interaction, immutable functions of time.
\item
  Multi-way constraints, with time-functions for variables.
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

\framet{1994--1996 at Microsoft Research: RBML/ActiveVRML}{

\begin{itemize}
\item
  Programming model \& fast implementation for new 3D hardware.
\item
  Goal: TBAG + denotative/functional reactivity.
\item
  Drop constraints ``at first''.
\item
  Add event algebra to behavior algebra.
\item
  Reactivity via behavior-valued events.
\item
  Started in ML as ``RBML''.
\item
  Rebranded to
   ``\href{http://conal.net/papers/ActiveVRML/}{ActiveVRML}'', then
   ``\href{http://www.sworks.com/keng/da.html}{DirectAnimation}''.
\end{itemize}
}

\framet{1996--1999 at MSR: RBMH/Fran}{

\begin{itemize}\parskip2ex
\item
  Found Haskell: reborn as ``RBMH'' (research vehicle).
\item
  Paul Hudak suggested names ``Fran'' and then ``FRP''.
\item
  Very fast implementation via sprite engine.
  (\href{http://conal.net/papers/padl99/}{paper})
\end{itemize}

}

\framet{2000 at MSR: first push-based implementation}{

\begin{itemize}\itemsep3ex
\item
  Algebra of event listeners.
\item Challenges:
 \begin{itemize}
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

\begin{itemize}
\item
  Modernized API:
  \begin{itemize}
  \itemsep1pt\parskip0pt\parsep0pt
  \item
    Standard abstractions.
  \item
    Semantics as homomorphisms.
  \item
    Laws for free.
  \end{itemize}
\item
  Push for reactivity and pull for continuous phases.
\item
  Reactive normal form, via equational properties (denotation!).
\item
  ``Push'' is really blocked pull.
\item
  Uses LUB (basis of PL semantics).
\item
  Implementation subtleties \& GHC RTS bugs. Didn't quite work.
  
\end{itemize}

}

\end{document}
