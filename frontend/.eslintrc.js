module.exports = {
  root: true,
  env: { browser: true, es6: true, node: true },
  extends: ['plugin:vue/essential', 'eslint:recommended'],
  parserOptions: { parser: 'babel-eslint', ecmaVersion: 2018, sourceType: 'module' },
  rules: {
    'no-console': 'off',
    'no-unused-vars': ['warn', { args: 'none' }]
  }
}
