
# ![PlayFrame](https://avatars3.githubusercontent.com/u/47147479)

###### 4 kB 60 fps Functional SPA/PWA Framework

[framesync](https://github.com/Popmotion/framesync) +
[React](https://github.com/facebook/react/) +
[Redux](https://github.com/reduxjs/redux) +
[Router](https://github.com/playframe/router) +
[Shadow Dom Components](https://developers.google.com/web/fundamentals/web-components/shadowdom)
alike minimalistic functional framework built to be able to update DOM
up to 60 times per second.
[Stateful Web Components](https://github.com/playframe/component)
can rerender independetly and incaplulate styles with Shadow DOM.
Comes with a very light trie router implementation

High performance server side rendering for PWA support is coming soon

##### SPA Example
```js
import {h, app, mount} from '@playframe/playframe'
app({
  // state
  counter: 1,
  // actions
  _: {
    inc: (e, state)=> state.counter++, // mutating
    dec: (e, {counter})=> ({counter: counter - 1}) // or returning object
  }
})( // view
  (state)=>
    <div>
      <h1>Counter: {state.counter}</h1>
      <button onclick={state._.inc}>Increment</button>
      <button onclick={state._.dec}>Decrement</button>
    </div>
  }
)( // dom container
  mount(document.body)
)
```

##### Routed Example
```js
import {h, route, mount} from '@playframe/playframe'
route({
  greeting: "Hello",
  routes: {
    '/': ()=> <a href="/hello/world"><h1>Link</h1></a>,
    '/hello/:name': ({state, param})=> <h1>{state.greeting} {param.name}!</h1>,
    '/*': ()=>  <h1>404</h1>
  }
})(
  mount(document.body)
)
```

## Installation
Using npm or yarn
```sh
npm i @playframe/playframe
```
Using UNPKG for es6 bundle
```uri
https://unpkg.com/@playframe/playframe@1.0.0/dist/playframe.min.js
```


## API

#### `PlayFrame.app(state_actions)(View)(container)`:
Creates a new `app` and mounts it into `container`. Initial `state_actions` will
create a `statue`
instance that will be passed into the `View` function

#### `PlayFrame.route(state_actions)(container)`:
Creates a new routed app and mounts it into `container`. Initial `state_actions`
should have a `routes` property

#### `PlayFrame.mount(domNode)`:
Creates a [ShaDOM](https://github.com/playframe/shadom)
container for managing DOM mutations

#### `PlayFrame.h(nodeName, attributes, children...)`:
Returns a lightweight [Virtual DOM](https://github.com/playframe/h)
node. If you are using JSX you might need
`["@babel/plugin-transform-react-jsx", { "pragma": "h" }]`. Or you could use
[rollup](https://github.com/rollup/rollup)
with [buble](https://github.com/rollup/rollup-plugin-buble)({jsx: 'h'})

#### `PlayFrame.Component(state_actions)(View)(upgrade)(props)`:
Creates a [Stateful Web Component](https://github.com/playframe/component)
function for given `state_actions`, `View` and
`upgrade`. `upgrade` will extent `state_actions` by using
[`evolve`](https://github.com/playframe/evolve) function. Passing `props` to
Component function will return Virtual DOM nodes. Styles are incaplulated by
[Shadow Dom](https://developers.google.com/web/fundamentals/web-components/shadowdom)
Example:
```js
const createHover = PlayFrame.Component({
  i: 0,
  _: {add: (e, state)=> state.i++}
})((state)=>
  <hover onhover={state._.add}>
    <style>{`
      :host {
        display: block;
        border: ${state.i}px;
      }
    `}</style>
    <h6>This was hovered {state.i} times</h6>
  </hover>
)
let Hover = createHover({
  i: 1, // lets start with 1
  _: { // and log increments
    add: (add)=>(e, state)=> {
      console.log('incremented')
      return add(e, state)
    }
  }
})
let View = (state)=> <Hover></Hover>
```

#### `PlayFrame.use(pureComponents)`:
Registering custom elements for Pure Components. Example:
```js
PlayFrame.use({
  'custom-heading': (props)=> <h1>{props.children}</h1>
})
const View = ()=> <custom-heading>Hello!</custom-heading>
```

#### `PlayFrame.reuse(statefulComponents)`:
Registering custom elements for
[Stateful Components](https://github.com/playframe/component).
To reuse the same Component
instanses we cache them in
[WeakMap](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap)
by `mkey` property which needs to be an object, not a primitive value.
Example:
```js
PlayFrame.reuse({
  'custom-stateful': PlayFrame.Component({
      i: 0,
      _: { add: (n)=>(e, state)=> state.i += n }
    })(
      (state)=>
        <custom-stateful>
          <h6>{state.i}</h6>
          <button onclick={state._.add(1)}>ADD 1</button>
          <button onclick={state._.add(10)}>ADD 10</button>
        </custom-stateful>
    )
})

const counters = [{i: 1}, {i: 10}, {i: 100}]

const View = ()=> counters.map((obj)=>
  <custom-stateful mkey={obj} i={obj.i}></custom-stateful>
)
```

### Internal functions

#### `PlayFrame.statue(state_actions, delayed, subscribe)`:
Creates a [statue](https://github.com/playframe/shadom) state machine
for a `state_actions` object. `delayed` will throttle state updates and
latest state will be passed to `subscribe` function. Example:
```js
const state_actions = {
  // state
  i: 0,
  // actions
  _: { add: (e, state)=> state.i++ },
  subCounter: {
    // nested state
    i: 0,
    // nested actions
    _: { add: (e, state)=> state.i++ },
  }
}
state = PlayFrame.statue(state_actions, requestIdleCallback, (state)=>
  console.log(state)
)
state._.add()
state.subCounter._.add()
// Will log on idle
// {i: 1, subCounter: {i: 1, _: {add}}, _: {add}}
```

#### `PlayFrame.evolve(base, upgrade)`:
Function for deep object extending. If any value in upgrade is function it
gets called with existing value as argument. Example:
```js
const base = {
  i: 1,
  j: 2,
  onclick: (e)=>{}
}
const upgrade = {
  i: 10, // overwrite value
  j: (j)=> j * 2, // double existing value
  onclick: (onclick)=>(e)=> { // compose functions
    console.log('click')
    onclick(e); // original handler
  }
console.log(PlayFrame.evolve(base, upgrade))
// {i: 10, j: 4, onclick: loggedOnClick}
}
```

#### `PlayFrame.sync.{next, catch, then, finally, render, frame}`:
Initialized instance of [OverSync](https://github.com/playframe/oversync) that
helps different parts of framework synchronize execution within unified frame
rendering flow

## Source

    sync = require('@playframe/oversync') Date.now, requestAnimationFrame
    exports.sync = sync

    exports.Component = require('@playframe/component') sync
    exports.mount = require('@playframe/shadom') sync
    router = require('@playframe/router') sync

    exports.statue = statue = require '@playframe/statue'
    exports.evolve = require '@playframe/evolve'


    exports.app = app = (state_actions)=>(view)=>(container)=>
      state_actions._ or= {}
      state = statue state_actions, sync.finally, (state)=>
        container view, state
      container view, state
      state


    exports.route = (state_actions)=> app(state_actions) router


    exports.h = h = require '@playframe/h'
    exports.use = h.use

    exports.reuse = (components)=>
      purified = {}
      for k, Component of components
        purified[k] = (props)=>
          mkey = props and props.mkey
          Component(mkey and {mkey}) props
      use purified