# beman.nullable: C++29 A Nullable Monad

<!--
SPDX-License-Identifier: 2.0 license with LLVM exceptions
-->

<!-- markdownlint-disable -->
<img src="https://github.com/bemanproject/beman/blob/main/images/logos/beman_logo-beman_library_production_ready_api_may_undergo_changes.png" style="width:5%; height:auto;"> ![CI Tests](https://github.com/steve-downey/nullable/actions/workflows/ci.yml/badge.svg) [![Coverage](https://coveralls.io/repos/github/steve-downey/nullable/badge.svg?branch=main)](https://coveralls.io/github/steve-downey/nullable?branch=main)
<!-- markdownlint-enable -->

## Rationale

Types such as smart pointers, raw pointers, optional, expected and others are a kind of monad. Using the Functor and Monad interfaces currently in optional and expected are safer than naive direct use of * or ->. These operations should be generalized to all types with similar interfaces.
Additional safer operations, which are not strictly speaking monadic, such as value_or, should also be provided, as they have proved useful.

## The Nullable Monad

Nullable types are, in C++, types with a contextual conversion to bool which indicates they contain a value, and * and -> operators that provide access to the contained value, such that (\*n).v is equivalent to n->v. It may be that operator->() is not strictly necessary, and that only operator\*() is required, but they generally come as a set and help confirm intent to conform to being 'pointer-like'.

The operations that must exist for a type to be a monad, which is also by necessity a functor and an applicative:

- map
- unit (pure, return)
- ap (<*>)
- bind (>>=)
- join

This is not a minimal basis set as there are several possible choices of operations to define a monad, but seeing what they each do for a particular monad instance helps build intuition about the monad instance. In general, knowing that some structure is monadic does not tell you what the operations do, only that some combinations must be equivalent and respect certain equivalances with respect to the identity function and associativity.

### map

The map operation takes a callable and, if the nullable contains a value, applies the callable to the value, returning a nullable that is empty if the nullable was empty, or a nullable that contains the value. This nullable does not have to be of the same type.

auto map(nullable<A> auto n, A->B) -> nullable<B>

### unit

The unit (pure, return, just) operation takes a value and returns a nullable holding that value.

auto unit(A a) -> nullable<A>

### ap

Applicative functors are really about n-ary functions for functors. Functional languages often only make explicit the 2-ary version, and assume currying or application to extend to higher cardinality functions. C++ does not usually make applicative explicit.

auto ap(nullable<A -> B> auto n, nullable<A> auto a) -> nullable<B>

### bind

auto bind(nullable<A> auto a, callable<A -> nullable<B>> auto f) -> nullable<B>

Bind is also sometimes called flat_map, as it 'flattens' a map where the functorial map would return a nullable<nullable<B>>, bind collapses the type.

### join

auto join(nullable<nullable<A>> auto a) -> nullable<A>

The isolated flatten operation.

## Additional APIs

### nullable::value_or

auto value_or(nullable<A> a, B b) -> common type of A and B

Returns either the value held by a or the value b, as the common type of A and B, as if by ternary operator.

### nullable::reference_or

auto reference_or(nullable<A> a, B b) -> common reference type of A and B
Returns either a reference to the  value held by a or a reference to the  value b, as the common reference type of A and B, as if by ternary operator.
