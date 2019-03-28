import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs'
import buble from 'rollup-plugin-buble'


export default {
  input: './index.js',
  plugins: [
    buble( {jsx: 'h', target: {chrome: 71}} ),
    resolve(),
    commonjs({ extensions: ['.js']} )
  ],
  output: {
    file: 'dist/playframe.js',
    name: 'PlayFrame',
    format: 'umd',
    sourcemap: true
  }
};
