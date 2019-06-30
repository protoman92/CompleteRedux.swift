# CompleteRedux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![CocoaPods](https://img.shields.io/cocoapods/v/CompleteRedux.svg)
[![Build Status](https://travis-ci.org/protoman92/CompleteRedux.svg?branch=master)](https://travis-ci.org/protoman92/CompleteRedux)
[![Coverage Status](https://codecov.io/gh/protoman92/CompleteRedux/branch/master/graph/badge.svg)](https://codecov.io/gh/protoman92/CompleteRedux/branch/master/graph/badge.svg)

Redux implementations for iOS clients.

## Motivation

As much as I love [RxSwift](https://github.com/ReactiveX/RxSwift) in development, it sometimes creates lots of noises and can prove challenging to unit-test. Having spent the past year as a React.js developer, I was looking forward to using Redux in iOS applications as well, but the current, most popular implementation of [Redux](https://github.com/ReSwift/ReSwift) is lacking in several key aspects as compared to the original **redux**/**react-redux** source:

- View controllers still know too much - in React.js, we have the wonderful **connect** function that invokes **mapState/DispatchToProps**, but here we are stuck with calling **store.dispatch(Action)**. The views are not supposed to know what actions to dispatch;
- Subscription and unsubscription are still done manually with **store.(un)subscribe(self)** - if I do not want to use a singleton, what should I do?
- Asynchronous work handling is still muddy. Over at React.js we run **redux-saga** or **redux-thunk**, but no such things exist here;

## Main features

This library provides:

- A simple, thread-safe [Redux store](https://github.com/protoman92/CompleteRedux/tree/master/CompleteRedux/SimpleStore);
- [Middleware support](https://github.com/protoman92/CompleteRedux/tree/master/CompleteRedux/Middleware);
- [Prop injection](https://github.com/protoman92/CompleteRedux/tree/master/CompleteRedux/UI) for a Redux-compatible view/view controller;
- A [Router middleware](https://github.com/protoman92/CompleteRedux/tree/master/CompleteRedux/Middleware%2BRouter) implementation;
- A side effect model ([Redux-Saga](https://github.com/protoman92/CompleteRedux/tree/master/CompleteRedux/Middleware%2BSaga), as inspired by [redux-saga](https://github.com/redux-saga/redux-saga)) to handle asynchronous work;

## Documentation

For a deeper look into how this works, check out the [full documentation](https://protoman92.github.io/CompleteRedux/), the [sample app](https://github.com/protoman92/ReduxForSwift) and some articles I wrote:

- [Redux for Swift (Part 1) - The Basics](https://medium.com/@swiften.svc/redux-for-swift-part-1-the-basics-7b66d73db7fa)
- [Redux for Swift (Part 2) - Automatic Subscription](https://medium.com/@swiften.svc/redux-for-swift-part-2-automatic-subscription-569658eb087f)
- [Redux for Swift (Part 3) - OutProps](https://medium.com/@swiften.svc/redux-for-swift-part-3-outprops-3e754965581a)
- [Redux for Swift (Part 4) - Routing and Navigation](https://medium.com/@swiften.svc/redux-for-swift-part-4-routing-and-navigation-3f445892d70e)
- [Redux for Swift (Part 5) - Asynchronous Work](https://medium.com/@swiften.svc/redux-for-swift-part-5-asynchronous-work-567a21e3dc26)
- [Redux for Swift (Part 6) - Unit Testing](https://medium.com/@swiften.svc/redux-for-swift-part-6-unit-testing-15ce5b002b40)
