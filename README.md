# ArelHash

[![Build Status](http://img.shields.io/travis/UP-nxt/arel_hash.svg)](https://travis-ci.org/UP-nxt/arel_hash)

ArelHash is a library that offers some utilities for serializing/deserializing Arel expressions into/from hashes.
At the heart of the where part of such an ArelHash expression, we have core expressions in the form of: 

 ``` { <predication>: { <left_operand> => <right_operand> } } ```
  
with ```operand``` being a 'column name' if it is a symbol, or a constant otherwise.
 
These expressions can be combined using *OR* and/or *AND*:
 
    { or: [ <subexpression>, <subexpression>, ... ] }
    { and: [ <subexpression>, <subexpression>, ... ] }
 
 
