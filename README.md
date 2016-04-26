# ArelHash

[![Join the chat at https://gitter.im/UP-nxt/arel_hash](https://badges.gitter.im/UP-nxt/arel_hash.svg)](https://gitter.im/UP-nxt/arel_hash?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](http://img.shields.io/travis/UP-nxt/arel_hash.svg)](https://travis-ci.org/UP-nxt/arel_hash)

ArelHash is a library that offers some utilities for serializing/deserializing Arel expressions into/from hashes.
At the heart of the where part of such an ArelHash expression, we have core expressions in the form of: 

 ``` { <predication>: { <left_operand> => <right_operand> } } ```
  
with ```operand``` being a 'column name' if it is a symbol, or a constant otherwise.
 
These expressions can be combined using *OR* and/or *AND*:
 
    { or: [ <subexpression>, <subexpression>, ... ] }
    { and: [ <subexpression>, <subexpression>, ... ] }
 
 ## Contributing
 
 ```bundle exec appraisal rspec```
 
