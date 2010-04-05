What
====

Herdis is a toy, study project, a proof of concept implementation of simple in-memory key-value storage with network interface and simple custom text protocol. Name is inspired by Redis.

See `client-test.py` with tests and `bench-report` with test times.


What i've learned
=================

- Creating network servers in Haskell is possible and even is easy. See Database/HerdisServer/Server.hs acceptLoop and clientLoop.
- Using STM (software transactional memory) in Haskell is simple and easy too.
- Biggest problem to speed is, surprisingly, protocol parsing speed.
- It is very easy to port existing Parsec String parsers to Attoparsec ByteString parsers.
- Using Cabal to build application is easy and productive (i.e. `runhaskell Setup.hs build` is close to good old 'make' in effect)
  Too bad, you can't specify several commands on line, like `runhaskell Setup.hs configure build`.
- Profiling Haskell applications using +RTS -P requires to rebuild the application with profiling support.
  But provides readable, easy to understand report.
  And using `runhaskell Setup.hs configure --enable-library-profiling --enable-executable-profiling` in turn, requires 'profiling version' of used libraries, i.e. Attoparsec.
  But simply using `GHC-Options: -O2 -auto-all -prof` in app.cabal file doesn't require 'profiling version' of used libraries.
- Using GHC threaded runtime with -threaded compilation flag actually makes this particular program slower.
  But faster when serving multiple concurrent clients (still slower than non-threaded runtime), which proves that forkIO works in parallel.
  `Control.Parallel.par` annotations gave no speed up in this particular program. Maybe because i used them incorrectly, or something else.

