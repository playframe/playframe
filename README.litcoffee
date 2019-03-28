
![PlayFrame](https://avatars3.githubusercontent.com/u/47147479)
# PlayFrame

###### 4 kB 60 fps Functional SPA/PWA Framework

## Installation
```sh
npm install --save @playframe/playframe
```

## Description
React + Redux alike minimalistic functional framework built on top of
[frame rendering engine](https://github.com/playframe/oversync)
to be able to update DOM 60 times per second.
[Stateful Web Components](https://github.com/playframe/component)
can rerender independetly and incaplulate styles with Shadow DOM.
Comes with router
High performance server side implementation for PWA support is coming soon

## Usage
```js
import {h, app, route, mount, Component} from '@playframe/playframe'
// SPA
app({
  //state
  counter: 1,
  // actions
  _: {
    inc: (e, state)=> state.counter++, // mutating
    dec: (e, {counter})=> ({counter: counter - 1}) // or returning object
  }
})( // view
  function CounterView(state) {
    return <div>
      <h1>Counter: {state.counter}</h1>
      <button onclick={state._.inc}>Increment</button>
      <button onclick={state._.dec}>Decrement</button>
    </div>
  }
)( // dom container
  mount(document.body)
)

// Or using router
route({
  counter: 1,
  _: {
    inc: (e, state)=> state.counter++,
    dec: (e, state)=> state.counter--
  },
  routes: {
    '/': ({state})=> <a href="/hello/world"><h1>Link</h1></a>,
    '/counter': ({state})=> CounterView(state),
    '/hello/:name': ({state, param})=> <h1>Hello {param.name}!</h1>,
    '/*': ()=>  <h1>404</h1>
  }
})(
  mount(document.body)
)
```

## Docs [WIP]

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
